#! /bin/bash

#TODO make sure bash header is needed

# Begin /etc/profile.d/aa_cfpProfileStart.sh
# This script should run as the first script launched in the profile.d dir (the aa_ prefix is meant to ensure this)
# It will set up for the standard Linux profile used on all systems.

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# don't keep a permanent history file for root (some people do this as security precaution)
# not active
# if [ $EUID -eq 0 ] ; then
#        pathappend /sbin:/usr/sbin
#        unset HISTFILE
# fi

# If the var has been set somewhere take it, otherwise must take hardcoded default
if [ -z "$BASE_DIR" ] ;
  then
    BASE_DIR="/usr/local"
fi

# Setup some environment settings.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"
export HISTTIMEFORMAT="%d/%m/%y %T "

# Setup a red prompt for root and a green one for users.
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
CYAN="\[\e[1;36m\]"
YELLOW="\[\e[1;33m\]"
if [[ $EUID == 0 ]] ; then
  USERCOLOR="$RED"
else
  USERCOLOR="$GREEN"
fi
PS1="$CYAN[\D{%Y-%m-%d %H:%M.%S}] $GREEN\w$RED\$(parse_git_branch)\n$USERCOLOR[\u@$CYAN\h]$NORMAL \[\033(0\]b\[\033(B\] $NORMAL"

unset script RED GREEN YELLOW NORMAL USERCOLOR

# This will run the script that knows the current environment settings and will execute setEnv
#   (/usr/local/bin is hardcoded for now - have to start somewhere...)
source $BASE_DIR/bin/cfpRetrieveEnv.sh

LogStart "$*"
source $BIN_DIR/cfpSetProxyEnv.sh

# Aliases
alias lsa='ls -la'
alias la='ls -la'
alias cdad='cd $DATA_DIR'
alias cdap='cd $APP_DIR'
alias cdcfp='cd $APP_DIR'
alias cdb='cd $BIN_DIR'
alias cdetc='cd $ETC_DIR'
alias cdl='cd $LOG_DIR'
alias pse='ps -ef'
alias cfpenv='$BASE_DIR/bin/cfpRetrieveEnv.sh'
alias dc='dc=docker-compose'

LogStop

# End /etc/profile.d/aa_cfpProfileStart.sh
