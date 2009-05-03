# completion
autoload -U compinit
compinit

# Load ~/.zsh/func
fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

# automatically enter directories without cd
setopt auto_cd

# use vim as an editor
export EDITOR=mvim

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

# keep more history
export HISTSIZE=2100
export SAVEHIST=2000
export HISTFILE=$HOME/.zsh_history
setopt append_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history

export PATH=~/bin:/opt/local/bin:/opt/local/sbin:$PATH:/opt/local/libexec/git-core
export MANPATH=/opt/local/share/man:$MANPATH

export EDITOR="mate -w"
export ARCHFLAGS="-arch i386"
alias slice="ssh -p 6120 209.20.82.172"

export LC_CTYPE=en_US.UTF-8

