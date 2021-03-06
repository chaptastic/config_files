import os
import posixpath
import cPickle as pickle

from mercurial import hg
from mercurial import node
from mercurial import util as hgutil
from mercurial import error

import maps
import svnwrap
import svnrepo
import util
import svnexternals


def verify(ui, repo, *args, **opts):
    '''verify current revision against Subversion repository
    '''

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    ctx = repo[opts.get('rev', '.')]
    if 'close' in ctx.extra():
        ui.write('cannot verify closed branch')
        return 0
    srev = ctx.extra().get('convert_revision')
    if srev is None:
        raise hgutil.Abort('revision %s not from SVN' % ctx)

    srev = int(srev.split('@')[1])
    ui.write('verifying %s against r%i\n' % (ctx, srev))

    url = repo.ui.expandpath('default')
    if args:
        url = args[0]
    svn = svnrepo.svnremoterepo(ui, url).svn
    meta = repo.svnmeta(svn.uuid, svn.subdir)

    btypes = {'default': 'trunk'}
    if meta.layout == 'standard':
        branchpath = btypes.get(ctx.branch(), 'branches/%s' % ctx.branch())
    else:
        branchpath = ''
    svnfiles = set()
    result = 0
    for fn, type in svn.list_files(posixpath.normpath(branchpath), srev):
        if type != 'f':
            continue
        svnfiles.add(fn)
        fp = fn
        if branchpath:
            fp = branchpath + '/'  + fn
        data, mode = svn.get_file(posixpath.normpath(fp), srev)
        fctx = ctx[fn]
        dmatch = fctx.data() == data
        mmatch = fctx.flags() == mode
        if not (dmatch and mmatch):
            ui.write('difference in file %s' % fn)
            result = 1

    hgfiles = set(ctx)
    hgfiles.discard('.hgtags')
    hgfiles.discard('.hgsvnexternals')
    if hgfiles != svnfiles:
        missing = set(hgfiles).symmetric_difference(svnfiles)
        ui.write('missing files: %s' % (', '.join(missing)))
        result = 1

    return result


def rebuildmeta(ui, repo, args, **opts):
    """rebuild hgsubversion metadata using values stored in revisions
    """

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    dest = None
    if len(args) == 1:
        dest = args[0]
    elif len(args) > 1:
        raise hgutil.Abort('rebuildmeta takes 1 or no arguments')
    uuid = None
    url = repo.ui.expandpath(dest or 'default-push', dest or 'default')
    svn = svnrepo.svnremoterepo(ui, url).svn
    subdir = svn.subdir
    svnmetadir = os.path.join(repo.path, 'svn')
    if not os.path.exists(svnmetadir):
        os.makedirs(svnmetadir)

    revmap = open(os.path.join(svnmetadir, 'rev_map'), 'w')
    revmap.write('1\n')
    last_rev = -1
    branchinfo = {}
    noderevnums = {}
    tagfile = os.path.join(svnmetadir, 'tagmap')
    if os.path.exists(maps.TagMap.filepath(repo)):
        os.unlink(maps.TagMap.filepath(repo))
    tags = maps.TagMap(repo)

    layout = None

    skipped = set()

    numrevs = len(repo)
    for rev in repo:
        util.progress(ui, 'rebuild', rev, total=numrevs)
        ctx = repo[rev]
        convinfo = ctx.extra().get('convert_revision', None)
        if not convinfo:
            continue
        if '.hgtags' in ctx.files():
            parent = ctx.parents()[0]
            parentdata = ''
            if '.hgtags' in parent:
                parentdata = parent.filectx('.hgtags').data()
            newdata = ctx.filectx('.hgtags').data()
            for newtag in newdata[len(parentdata):-1].split('\n'):
                ha, tag = newtag.split(' ', 1)
                tagged = repo[ha].extra().get('convert_revision', None)
                if tagged is None:
                    tagged = -1
                else:
                    tagged = int(tagged[40:].split('@')[1])
                # This is max(tagged rev, tagging rev) because if it is a normal
                # tag, the tagging revision has the right rev number. However, if it
                # was an edited tag, then the tagged revision has the correct revision
                # number.
                tagging = int(convinfo[40:].split('@')[1])
                tagrev = max(tagged, tagging)
                tags[tag] = node.bin(ha), tagrev

        # check that the conversion metadata matches expectations
        assert convinfo.startswith('svn:')
        revpath, revision = convinfo[40:].split('@')
        if subdir and subdir[0] != '/':
            subdir = '/' + subdir
        if subdir and subdir[-1] == '/':
            subdir = subdir[:-1]
        assert revpath.startswith(subdir), ('That does not look like the '
                                            'right location in the repo.')

        if layout is None:
            if (subdir or '/') == revpath:
                layout = 'single'
            else:
                layout = 'standard'
            f = open(os.path.join(svnmetadir, 'layout'), 'w')
            f.write(layout)
            f.close()
        elif layout == 'single':
            assert (subdir or '/') == revpath, ('Possible layout detection'
                                                ' defect in replay')

        # write repository uuid if required
        if uuid is None:
            uuid = convinfo[4:40]
            assert uuid == svn.uuid, 'UUIDs did not match!'
            uuidfile = open(os.path.join(svnmetadir, 'uuid'), 'w')
            uuidfile.write(uuid)
            uuidfile.close()

        # don't reflect closed branches
        if (ctx.extra().get('close') and not ctx.files() or
            ctx.parents()[0].node() in skipped):
            skipped.add(ctx.node())
            continue

        # find commitpath, write to revmap
        commitpath = revpath[len(subdir)+1:]
        if layout == 'standard':
            if commitpath.startswith('branches/'):
                commitpath = commitpath[len('branches/'):]
            elif commitpath == 'trunk':
                commitpath = ''
            else:
                if commitpath.startswith('tags/') and ctx.extra().get('close'):
                    continue
                commitpath = '../' + commitpath
        else:
            commitpath = ''
        revmap.write('%s %s %s\n' % (revision, ctx.hex(), commitpath))

        revision = int(revision)
        noderevnums[ctx.node()] = revision
        if revision > last_rev:
            last_rev = revision

        # deal with branches
        if ctx.extra().get('close'):
            continue
        branch = ctx.branch()
        if branch == 'default':
            branch = None
        if branch not in branchinfo:
            parent = ctx.parents()[0]
            if (parent.node() in noderevnums
                and parent.branch() != ctx.branch()):
                parentbranch = parent.branch()
                if parentbranch == 'default':
                    parentbranch = None
            else:
                parentbranch = None
            branchinfo[branch] = (parentbranch,
                                  noderevnums.get(parent.node(), 0),
                                  revision)
        droprev = lambda x: x.rsplit('@', 1)[0]
        for cctx in ctx.children():
            # check if a child of this change closes this branch
            # that's true if the close flag is set and the svn revision
            # path is the same. droprev removes the revnumber so we
            # can verify it is the same branch easily
            if (cctx.extra().get('close')
                and droprev(cctx.extra().get('convert_revision', '@')) == droprev(convinfo)):
                branchinfo.pop(branch, None)
                break
    util.progress(ui, 'rebuild', None, total=numrevs)

    # save off branch info
    branchinfofile = open(os.path.join(svnmetadir, 'branch_info'), 'w')
    pickle.dump(branchinfo, branchinfofile)
    branchinfofile.close()


def help(ui, args=None, **opts):
    """show help for a given subcommands or a help overview
    """
    if args:
        subcommand = args[0]
        if subcommand not in table:
            candidates = []
            for c in table:
                if c.startswith(subcommand):
                    candidates.append(c)
            if len(candidates) == 1:
                subcommand = candidates[0]
            elif len(candidates) > 1:
                ui.status('Ambiguous command. Could have been:\n%s\n' %
                          ' '.join(candidates))
                return
        doc = table[subcommand].__doc__
        if doc is None:
            doc = "No documentation available for %s." % subcommand
        ui.status(doc.strip(), '\n')
        return
    ui.status(_helpgen())


def update(ui, args, repo, clean=False, **opts):
    """update to a specified Subversion revision number
    """

    assert len(args) == 1
    rev = int(args[0])
    meta = repo.svnmeta()

    answers = []
    for k, v in meta.revmap.iteritems():
        if k[0] == rev:
            answers.append((v, k[1]))

    if len(answers) == 1:
        if clean:
            return hg.clean(repo, answers[0][0])
        return hg.update(repo, answers[0][0])
    elif len(answers) == 0:
        ui.status('revision %s did not produce an hg revision\n' % rev)
        return 1
    else:
        ui.status('ambiguous revision!\n')
        revs = ['%s on %s' % (node.hex(a[0]), a[1]) for a in answers] + ['']
        ui.status('\n'.join(revs))
    return 1


def genignore(ui, repo, force=False, **opts):
    """generate .hgignore from svn:ignore properties.
    """

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    ignpath = repo.wjoin('.hgignore')
    if not force and os.path.exists(ignpath):
        raise hgutil.Abort('not overwriting existing .hgignore, try --force?')
    svn = svnrepo.svnremoterepo(repo.ui).svn
    meta = repo.svnmeta()
    hashes = meta.revmap.hashes()
    parent = util.parentrev(ui, repo, meta, hashes)
    r, br = hashes[parent.node()]
    if meta.layout == 'single':
        branchpath = ''
    else:
        branchpath = br and ('branches/%s/' % br) or 'trunk/'
    ignorelines = ['.hgignore', 'syntax:glob']
    dirs = [''] + [d[0] for d in svn.list_files(branchpath, r)
                   if d[1] == 'd']
    for dir in dirs:
        path = '%s%s' % (branchpath, dir)
        props = svn.list_props(path, r)
        if 'svn:ignore' not in props:
            continue
        lines = props['svn:ignore'].strip().split('\n')
        ignorelines += [dir and (dir + '/' + prop) or prop for prop in lines]

    repo.wopener('.hgignore', 'w').write('\n'.join(ignorelines) + '\n')


def info(ui, repo, **opts):
    """show Subversion details similar to `svn info'
    """

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    meta = repo.svnmeta()
    hashes = meta.revmap.hashes()

    if opts.get('rev'):
        parent = repo[opts['rev']]
    else:
        parent = util.parentrev(ui, repo, meta, hashes)

    pn = parent.node()
    if pn not in hashes:
        ui.status('Not a child of an svn revision.\n')
        return 0
    r, br = hashes[pn]
    subdir = parent.extra()['convert_revision'][40:].split('@')[0]
    if meta.layout == 'single':
        branchpath = ''
    elif br == None:
        branchpath = '/trunk'
    elif br.startswith('../'):
        branchpath = '/%s' % br[3:]
        subdir = subdir.replace('branches/../', '')
    else:
        branchpath = '/branches/%s' % br
    remoterepo = svnrepo.svnremoterepo(repo.ui)
    url = '%s%s' % (remoterepo.svnurl, branchpath)
    author = meta.authors.reverselookup(parent.user())
    # cleverly figure out repo root w/o actually contacting the server
    reporoot = url[:len(url)-len(subdir)]
    ui.write('''URL: %(url)s
Repository Root: %(reporoot)s
Repository UUID: %(uuid)s
Revision: %(revision)s
Node Kind: directory
Last Changed Author: %(author)s
Last Changed Rev: %(revision)s
Last Changed Date: %(date)s\n''' %
              {'reporoot': reporoot,
               'uuid': meta.uuid,
               'url': url,
               'author': author,
               'revision': r,
               # TODO I'd like to format this to the user's local TZ if possible
               'date': hgutil.datestr(parent.date(),
                                      '%Y-%m-%d %H:%M:%S %1%2 (%a, %d %b %Y)')
              })


def listauthors(ui, args, authors=None, **opts):
    """list all authors in a Subversion repository
    """
    if not len(args):
        ui.status('No repository specified.\n')
        return
    svn = svnrepo.svnremoterepo(ui, args[0]).svn
    author_set = set()
    for rev in svn.revisions():
        author_set.add(str(rev.author)) # So None becomes 'None'
    if authors:
        authorfile = open(authors, 'w')
        authorfile.write('%s=\n' % '=\n'.join(sorted(author_set)))
        authorfile.close()
    else:
        ui.write('%s\n' % '\n'.join(sorted(author_set)))


def _helpgen():
    ret = ['hg svn ...', '',
           'subcommands for Subversion integration', '',
           'list of subcommands:', '']
    for name, func in sorted(table.items()):
        if func.__doc__:
            short_description = func.__doc__.splitlines()[0]
        else:
            short_description = ''
        ret.append(" %-10s  %s" % (name, short_description))
    return '\n'.join(ret) + '\n'


table = {
    'genignore': genignore,
    'info': info,
    'listauthors': listauthors,
    'update': update,
    'help': help,
    'rebuildmeta': rebuildmeta,
    'updateexternals': svnexternals.updateexternals,
    'verify': verify,
}
