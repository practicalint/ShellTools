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

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

export -f pathremove pathprepend pathappend

# Set the initial path (removed to allow normal long term path retention
# export PATH=/bin:/usr/bin

# don't keep a permanent history file for root (some people do this as security precaution)
# not active
# if [ $EUID -eq 0 ] ; then
#        pathappend /sbin:/usr/sbin
#        unset HISTFILE
# fi

# Setup some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# Setup a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u@$NORMAL\h:\l $RED[\w]$NORMAL\\$ "
else
  PS1="$GREEN\u@$NORMAL\h:\l $GREEN[\w]$NORMAL\\$ "
fi

# If this script were used as /etc/profile, this would be needed to run profile.d add-ons
#   not active here
# for script in /etc/profile.d/*.sh ; do
#         if [ -r $script ] ; then
#                 . $script
#         fi
# done

unset script RED GREEN NORMAL

cfpSetApp cfpcore # set environment 
LogStart "$*"
 

# Aliases
alias lsa='ls -la'
alias la='ls -la'
alias cdad='cd $APPDATA'
alias cdap='cd $APPDIR'
alias cdcfp='cd $APPDIR'
alias pse='ps -ef'

LogStop

# End /etc/profile.d/aa_cfpProfileStart.sh
EOF