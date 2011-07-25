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

# prompt adam2

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

export PATH=~/bin:$PATH
export MANPATH=/opt/local/share/man:$MANPATH

export EDITOR="mvim -f"
# export EDITOR="mvim -f -c \\"au VimLeave * !open -a Terminal\\""
#export EDITOR="$HOME/bin/emc"
#export EDITOR="mate -w"
#export EDITOR="${HOME}/bin/ec"
# export ARCHFLAGS="-arch x86_64"

export LC_CTYPE=en_US.UTF-8

# aliases
if [ -e "$HOME/.zsh_local" ]; then
  source "$HOME/.zsh_local"
fi

#export GOROOT=$HOME/Projects/go
#export GOOS=darwin
#export GOARCH=amd64
#export GOBIN=$HOME/bin

# export JAVA_HOME=/Library/Java/Home
# export CATALINA_HOME=/Library/Tomcat/Home
#export JUNIT_HOME=$HOME/build/junit4.8.1
#export CLASSPATH=$CLASSPATH:$JUNIT_HOME/junit-4.8.1.jar

# export MAVEN_OPTS="-Xmx1024m"
# export ANT_OPTS="-Xmx1024m"
