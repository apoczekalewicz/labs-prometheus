sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mkdir /etc/alertmanager

cd /tmp/
wget -nc https://github.com/prometheus/alertmanager/releases/download/v0.16.1/alertmanager-0.16.1.linux-amd64.tar.gz
tar -xvf alertmanager-0.16.1.linux-amd64.tar.gz

cd alertmanager-0.16.1.linux-amd64
sudo mv alertmanager /usr/local/bin/
sudo mv amtool /usr/local/bin/
chmod +x /usr/local/bin/*

sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

sudo mv alertmanager.yml /etc/alertmanager/

sudo chown -R alertmanager:alertmanager /etc/alertmanager/

cat > /etc/systemd/system/alertmanager.service << EOF
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml
[Install]
WantedBy=multi-user.target
EOF


sudo systemctl stop prometheus

echo "Add this to /etc/prometheus/prometheus.yml 
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093
"
echo "Waiting for ENTER"
read A

restorecon -R /etc/alertmanager /usr/local/bin
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
