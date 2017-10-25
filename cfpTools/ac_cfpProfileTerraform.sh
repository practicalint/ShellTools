#! /bin/bash

# Begin /etc/profile.d/ac_cfpProfileTerraform.sh
# Change path to accomodate Terraform.
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

# Setup some environment settings.
pathmunge $BIN_DIR/terraform after

LogStop

# End /etc/profile.d/ac_cfpProfileTerraform.sh
