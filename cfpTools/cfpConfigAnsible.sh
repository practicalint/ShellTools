#! /bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetCSPVars.sh
source $BIN_DIR/cfpSetProxyEnv.sh

WriteLog "Installing Ansible"
sudo -E yum -y install epel-release
sudo -E yum -y install ansible
STATUS=$(ansible --version)
WriteLog "Installed Ansible version $STATUS" 

LogStop
