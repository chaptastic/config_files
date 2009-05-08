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

export PATH=~/bin:/opt/local/bin:/opt/local/sbin:$PATH:/opt/local/libexec/git-core:~/ec2-tools/bin:~/.clojure/bin
export MANPATH=/opt/local/share/man:$MANPATH

export EDITOR="mvim -f"
export ARCHFLAGS="-arch i386"

export LC_CTYPE=en_US.UTF-8

export CLOJURE_CP=$HOME/.clojure/clojure.jar:$HOME/.clojure/clojure-contrib.jar

# aliases
if [ -e "$HOME/.zsh_local" ]; then
  source "$HOME/.zsh_local"
fi
