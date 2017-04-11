#!/usr/bin/bash
# Set a persistant hostname on an AWS Centos 7 instance
# following instructions from https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetCSPVars.sh

# NEW_HOSTNAME="cfpMgtTestDns01"
if [ -z "$CSP_HOSTNAME" ]; then
  NEW_HOSTNAME="$1"
  WriteLog "NO CSP_HOSTNAME, checking command line parms"
else
  NEW_HOSTNAME="$CSP_HOSTNAME"
  WriteLog "Found CSP_HOSTNAME = $CSP_HOSTNAME"
fi

OLD_HOSTNAME="$( hostname )"

if [ -z "$NEW_HOSTNAME" ]; then
 echo -n "Please enter new hostname: "
 read NEW_HOSTNAME < /dev/tty
fi

if [ -z "$NEW_HOSTNAME" ]; then
  WriteLog "Error: no hostname entered. Exiting."
  exit 1
fi

WriteLog "Changing hostname from $OLD_HOSTNAME to $NEW_HOSTNAME..."

hostname "$NEW_HOSTNAME"
export HOSTNAME=$NEW_HOSTNAME   # this may not be needed

# Update the /etc/sysconfig/network file with the following values:
#     NETWORKING=yes
# not doing    NETWORKING_IPV6=no
# not doing     HOSTNAME=persistent_host_name
WriteLog "Processing /etc/sysconfig/network"
if [ -n "$( grep "$OLD_HOSTNAME" /etc/sysconfig/network )" ]; then
 sed -i "s/HOSTNAME=.*/HOSTNAME=$NEW_HOSTNAME/g" /etc/sysconfig/network
else
 echo -e "HOSTNAME=$NEW_HOSTNAME" >> /etc/sysconfig/network
fi

# Update the /etc/hostname file on your RHEL 7 or Centos 7 Linux instance with the new hostname.
#   (I think the hostname command does this, but it doesn't stick after boot)
#     127.0.0.1 persistent_host_name localhost.localdomain localhost
WriteLog "Processing /etc/hostname"
if [ -n "$( grep "$OLD_HOSTNAME" /etc/hostname )" ]; then
 sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname
else
 echo -e "$( hostname -I | awk '{ print $1 }' )\t$NEW_HOSTNAME" >> /etc/hostname
fi

# Update the /etc/hosts file on your RHEL 7 or Centos 7 Linux instance with the new hostname.
# Change the entry beginning with 127.0.0.1 to read as follows:
#     127.0.0.1 persistent_host_name localhost.localdomain localhost
WriteLog "Processing /etc/hosts"
if [ -n "$( grep "$OLD_HOSTNAME" /etc/hosts )" ]; then
 sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
else
 echo -e "$( hostname -I | awk '{ print $1 }' )\t$NEW_HOSTNAME" >> /etc/hosts
fi

# Append the following string at the bottom of the file to ensure that the hostname is preserved between restarts/reboots.
#     preserve_hostname: true
WriteLog "Processing /etc/cloud/cloud.cfg"
if [ -n "$( grep "preserve_hostname:" /etc/cloud/cloud.cfg )" ]; then
 if [ -n "$( grep "preserve_hostname: false" /etc/cloud/cloud.cfg )" ]; then
  sed -i "s/"preserve_hostname: false"/"preserve_hostname: true"/g" /etc/cloud/cloud.cfg
 else
  echo -e "preserve_hostname: true is present"
 fi
else
 echo -e "preserve_hostname: true" >> /etc/cloud/cloud.cfg
fi

LogStop