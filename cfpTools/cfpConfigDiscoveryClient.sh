#! /bin/bash
source $BIN_DIR/cfpSetEnv.sh
cfpSetApp
LogStart "$*"

source $BIN_DIR/cfpSetCSPVars.sh
source $BIN_DIR/cfpSetProxyEnv.sh

WriteLog "Retrieving Consul binary"
cd $LIB_DIR
CONSUL_VER="0.8.0"
CONSUL_ZIP="consul_${CONSUL_VER}_linux_amd64.zip"
WriteLog "Consul Ver: ${CONSUL_VER} / Zip: ${CONSUL_ZIP}"
curl -s -O https://releases.hashicorp.com/consul/${CONSUL_VER}/${CONSUL_ZIP}
sudo unzip -o ${CONSUL_ZIP} -d /usr/local/bin/

WriteLog "Configuring Environment"
sudo adduser consul
sudo mkdir -p /etc/consul.d/{bootstrap,client,server,services}
sudo mkdir /var/consul
sudo chown -R consul:consul /var/consul
sudo ln -s /usr/local/bin/consul /usr/bin/consul
#The hard way? Next may not be always right... IPADDR=$(sudo ip addr |grep eth0 |grep inet |awk '{print$2}' |awk -F/ '{print$1}')
IPADDR="$(hostname -i)"
cat << EOF > /etc/consul.d/client/config.json
{
  "bootstrap": false,
  "server": false,
  "node_name": "$(hostname)",
 "datacenter": "cfpmanagement",
  "data_dir": "/var/consul",
  "log_level": "INFO",
  "enable_syslog": true,
  "bind_addr": "$IPADDR",
  "client_addr": "0.0.0.0",
  "leave_on_terminate": false,
  "skip_leave_on_interrupt": true,
  "rejoin_after_leave": true,
  "retry_join": ["10.10.10.226"]
}
EOF
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target
[Service]
User=consul
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -data-dir=/var/consul -config-file=/etc/consul.d/client/config.json -config-dir=/etc/consul.d/services/
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT
[Install]
WantedBy=multi-user.target
EOF

WriteLog "Preparing/Launching Service"
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul
sudo systemctl status consul

LogStop
