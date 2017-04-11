#!/bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetCSPVars.sh

DOMAIN=$(cat /etc/resolv.conf | grep search | cut -d " " -f 2)

WriteLog "Vars built INSTANCE_ID = $INSTANCE_ID , INSTANCE_IP = $INSTANCE_IP, CSP_HOSTNAME = $CSP_HOSTNAME, DOMAIN = $DOMAIN"

# TODO NEED TO PULL CERTS OUT OF VAULT - currently file Kadmin.management.cfp.+157+04455.private must be present

# cat<<EOF | /usr/bin/nsupdate -k Kadmin.management.cfp.+157+04455.private -v
WriteLog "Generating $BIN_DIR/updateHostDNS.sh"
cat << EOF > $ETC_DIR/updateHostDNS.txt
server dnsinternal.management.cfp
zone ${DOMAIN}
update delete ${CSP_HOSTNAME}.${DOMAIN} A
update add ${CSP_HOSTNAME}.${DOMAIN} 60 A ${INSTANCE_IP}
show
send
EOF

if [ $DEBUG_ON -eq $TRUE ]; then
    WriteLog "NOT Executing DNS Update: $BIN_DIR/updateHostDNS.sh"
    cat "$ETC_DIR/updateHostDNS.sh"
else
    WriteLog "Executing DNS Update: $DATA_DIR/updateHostDNS.txt"
	WriteLog "Run with: /usr/bin/nsupdate -k $ETC_DIR/Kadmin.management.cfp.+157+04455.private -v $ETC_DIR/updateHostDNS.txt"
    /usr/bin/nsupdate -k $ETC_DIR/Kadmin.management.cfp.+157+04455.private-bind -v $ETC_DIR/updateHostDNS.txt
fi

LogStop
