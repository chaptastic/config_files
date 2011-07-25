export PATH=$PATH:~/bin:~/Library/Haskell/bin
export CLICOLOR=1
export GEM_HOME='/usr/local/Cellar/gems/1.8'

shopt -s globstar autocd

set -o emacs

export EDITOR="mvim -f"

export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
export EC2_AMITOOL_HOME="/usr/local/Cellar/ec2-ami-tools/1.3-45758/jars"
export EC2_HOME="/usr/local/Cellar/ec2-api-tools/1.4.2.2/jars"

if [[ -d /usr/local/etc/bash_completion.d ]]; then
  for f in /usr/local/etc/bash_completion.d/*sh; do
    source $f
  done
fi
export PS1='\u@\h:\[\e[34m\]\W\[\e[0m\]$(__git_ps1 "(\[\e[32m\]%s\[\e[0m\])") [\!]\$ '

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
