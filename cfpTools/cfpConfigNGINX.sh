#! /bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetCSPVars.sh
source $BIN_DIR/cfpSetProxyEnv.sh

WriteLog "Installing NGINX"
sudo yum -y install epel-release
sudo yum -y install nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sleep 2
WriteLog "Statusing NGINX"
sudo systemctl status nginx

WriteLog "Registering Service with Registry"
curl -s http://discovery.management.cfp:8500/v1/kv/services/definitions/web-80?raw > /etc/consul.d/services/nginx.json
sudo systemctl reload consul
sleep 2
WriteLog "Statusing Consul"
sudo systemctl status consul

LogStop
