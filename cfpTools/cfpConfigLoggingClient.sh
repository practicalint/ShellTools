#! /bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetCSPVars.sh
source $BIN_DIR/cfpSetProxyEnv.sh

WriteLog "Retrieving logging service location from Registry"
ARRAY=( $(curl -s http://localhost:8500/v1/catalog/service/graylog-server?pretty |grep '"Address"' |awk -F '"' '{print$4}') )
WriteLog "logging service location = $ARRAY"
RANDOM=$$$(date +%s)
HEALTHYTARGET=${ARRAY[$RANDOM % ${#ARRAY[@]} ]}

WriteLog "Retrieving sidecar rpm"
cd $LIB_DIR
AGENT_VER="0.1.0"
AGENT_FILE="collector-sidecar-${AGENT_VER}-1.x86_64.rpm"
WriteLog "Agent Ver: ${AGENT_VER} / File: ${AGENT_FILE}"
wget https://github.com/Graylog2/collector-sidecar/releases/download/${AGENT_VER}/${AGENT_FILE}
sleep 2
WriteLog "Installing sidecar rpm"
sudo rpm -i ${AGENT_FILE}
sleep 2

status=$(sudo systemctl is-active collector-sidecar)
WriteLog "Sidecar status after RPM: $status"

if [ "$status" != "active" ]; then
  WriteLog "Installing sidecar service"
  sudo graylog-collector-sidecar -service install
  sleep 1
  sudo systemctl enable collector-sidecar
  sleep 1
  sudo systemctl start collector-sidecar
fi

#ToDo IP address needs to be a dns
WriteLog "configuring logging service"
sudo sed -i -e "s|server_url:.*|server_url: https://${HEALTHYTARGET}:9000/api|g" /etc/graylog/collector-sidecar/collector_sidecar.yml
sudo sed -i "/tls_skip_verify/c tls_skip_verify: true" /etc/graylog/collector-sidecar/collector_sidecar.yml
sleep 1
sudo systemctl restart collector-sidecar

LogStop
