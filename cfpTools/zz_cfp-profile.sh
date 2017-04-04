# custom login configuration for cfp users
# Setup a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
#  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
  PS1="$RED\u@$NORMAL\h:\l $RED[\w]$NORMAL\\$ "
else
#  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
  PS1="$GREEN\u@$NORMAL\h:\l $GREEN[\w]$NORMAL\\$ "
fi
#
# Environment
export ETSAPP=jira
export ETSAPPVER=5.1
export ETSAPPINST=test03
export CFPDIR=/usr/local/$cfpcore
export ATLDATA=/var/atlassian/application-data
export ATLAPP=/opt/atlassian
export APPDATA=$ATLDATA/$ETSAPP-$ETSAPPINST
export APPDIR=$ATLAPP/$ETSAPP$ETSAPPVER
export APP_HOME=$APPDIR
#
# Aliases
alias lsa='ls -la'
alias la='ls -la'
alias cdad='cd $APPDATA'
alias cdap='cd $APPDIR'
alias cdets='cd $ETSDIR'
alias pse='ps -ef'

