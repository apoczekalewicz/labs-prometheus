cd /tmp
sudo wget -nc -O node-exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

sudo tar -xvf node-exporter.tar.gz --strip-components=1
sudo rm node-exporter.tar.gz
sudo cp -f ./node_exporter /usr/local/bin/node_exporter
chmod +x /usr/local/bin/node_exporter
restorecon -R /usr/local/bin/*

printf "[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
After=network-online.target
[Service]
User=pi
Restart=on-failure
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node-exporter.service

sudo systemctl daemon-reload

sudo systemctl enable node-exporter.service
sudo systemctl start node-exporter.service
sudo systemctl status node-exporter.service
