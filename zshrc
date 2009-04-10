# completion
autoload -U compinit
compinit

# automatically enter directories without cd
setopt auto_cd

# use vim as an editor
export EDITOR=vim

# aliases
if [ -e "$HOME/.aliases" ]; then
  source "$HOME/.aliases"
fi

# vi mode
bindkey -v

# use incremental search
bindkey ^R history-incremental-search-backward

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='%n@%m: %~%# '

# ignore duplicate history entries
setopt histignoredups

# keep more history
export HISTSIZE=200


# MacPorts Installer addition on 2009-03-28_at_13:26:33: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


# MacPorts Installer addition on 2009-03-28_at_13:26:33: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH=/opt/local/share/man:$MANPATH
# Finished adapting your MANPATH environment variable for use with MacPorts.

export EDITOR="mate -w"
export ARCHFLAGS="-arch i386"
alias slice="ssh -p 6120 209.20.82.172"

export LC_CTYPE=en_US.UTF-8
