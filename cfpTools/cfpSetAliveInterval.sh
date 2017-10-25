#! /bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

WriteLog "Changing Client Alive Interval to proper setting"
# Add to Path with profile.d script addition
sudo sed -e -i "s/ClientAliveInterval 300/ClientAliveInterval 1200/"  /etc/ssh/sshd_config

WriteLog "Changed Client Alive Interval to proper setting" 

LogStop
