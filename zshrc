# completion
autoload -U compinit
compinit

# Load ~/.zsh/func
fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

# automatically enter directories without cd
setopt auto_cd

# aliases
if [ -e "$HOME/.aliases" ]; then
  source "$HOME/.aliases"
fi

# emacs mode
bindkey -e

# use incremental search
bindkey ^R history-incremental-search-backward

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='%n@%m: %~%# '

# Load the prompt theme system
autoload -U promptinit
promptinit

prompt adam2

# ignore duplicate history entries
setopt histignoredups

# keep more history
export HISTSIZE=200

export PATH=~/bin:/opt/local/bin:/opt/local/sbin:$PATH:/opt/local/libexec/git-core:~/ec2-tools/bin
export MANPATH=/opt/local/share/man:$MANPATH

export EDITOR="mvim -f"
export ARCHFLAGS="-arch i386"

export LC_CTYPE=en_US.UTF-8

# aliases
if [ -e "$HOME/.zsh_local" ]; then
  source "$HOME/.zsh_local"
fi
