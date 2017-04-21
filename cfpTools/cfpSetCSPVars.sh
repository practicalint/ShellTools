#!/bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetProxyEnv.sh

export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

export INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Not using AWS CLI for now anyway
# HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=Name" --output=text | cut -f5)
# export CSP_HOSTNAME=$(curl http://169.254.169.254/latest/user-data)
# this was if user-data is an export command:
# eval curl -s http://169.254.169.254/latest/user-data
export CSP_HOSTNAME=$(curl -s http://169.254.169.254/latest/user-data)

# temp until user-data fixed:
# export CSP_HOSTNAME=$CFP_HOSTNAME
WriteLog "Vars built INSTANCE_ID = $INSTANCE_ID , INSTANCE_IP = $INSTANCE_IP, CSP_HOSTNAME = $CSP_HOSTNAME"

LogStop
