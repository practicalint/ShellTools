#! /bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetCSPVars.sh
source $BIN_DIR/cfpSetProxyEnv.sh

WriteLog "Installing Terraform"
VERSION="0.9.4"
wget --directory-prefix=$LIB_DIR https://releases.hashicorp.com/terraform/"$VERSION"/terraform_"$VERSION"_linux_amd64.zip 
unzip $LIB_DIR/terraform_"$VERSION"_linux_amd64.zip -d $BIN_DIR/terraform
pathmunge $BIN_DIR/terraform
STATUS=$(terraform --version)

# Add to Path with profile.d script addition
sudo mv $BIN_DIR/ac_cfpProfileTerraform.sh /etc/profile.d
sudo chmod +x /etc/profile.d/ac_cfpProfileTerraform.sh

WriteLog "Installed Terraform version $STATUS" 

LogStop
