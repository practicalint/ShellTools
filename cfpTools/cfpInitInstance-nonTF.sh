#!/bin/bash
# This will set up the environment like when a new machine is provisioned with terraform
# Requirements: make sure wget, unzip are installed. Make sure all standard security groups are assigned.
# BIG: AWS user-data has to have just the name of the instance in it
# upload this file and cfpTools.zip to cfpadmin home, chmod +x script and run it (not as sudo)
#
mkdir ~/tmp
unzip ~/cfpTools.zip -d ~/tmp
chmod +x ~/tmp/cfpInitInstance.sh
~/tmp/cfpInitInstance.sh
