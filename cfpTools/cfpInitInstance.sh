#!/bin/bash

# Some Housekeeping - change these vars if desired/needed
BASE_DIR="/usr/local"
APP_INST=cfpcore
BIN_DIR=$BASE_DIR/$APP_INST/bin

# grab whose home dir is in use
HOME_DIR=~
TMP_DIR=$HOME_DIR/tmp

chmod +x $TMP_DIR/*.sh
sudo $TMP_DIR/cfpSetEnv.sh --appinstance $APP_INST --basedirectory $BASE_DIR --create

# source ${BASE_DIR}/bin/cfpRetrieveEnv.sh
source $TMP_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

WriteLog "moving everything into place"
sudo mv $TMP_DIR/aa*.sh /etc/profile.d
sudo chmod +x /etc/profile.d/aa*.sh
mv $TMP_DIR/cfp*.sh $BIN_DIR/.
chmod +x $BIN_DIR/*.sh
sudo -E chown $ADMIN_GROUP $BIN_DIR/cfp*.sh
sudo -E chgrp $ADMIN_GROUP $BIN_DIR/cfp*.sh

WriteLog "setting hostname"
sudo -E $BIN_DIR/cfpSetHostnameCentos7.sh

WriteLog "updating host into DNS"
mv $TMP_DIR/K*.private* $ETC_DIR/.
sudo -E $BIN_DIR/cfpUpdateDNSonBoot.sh
rm -f $ETC_DIR/K*.private*

WriteLog "Installing Discovery Client"
sudo -E $BIN_DIR/cfpConfigDiscoveryClient.sh

WriteLog "Installing Logging Client"
sudo -E $BIN_DIR/cfpConfigLoggingClient.sh

LogStop
