sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus -p
sudo mkdir /var/lib/prometheus -p
sudo chown prometheus:prometheus /var/lib/prometheus

cd /tmp/
wget -nc https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz


tar -xvf prometheus-2.7.1.linux-amd64.tar.gz


cd prometheus-2.7.1.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo chmod +x /usr/local/bin/*
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

cat > /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

restorecon -R /etc/prometheus /var/lib/prometheus /usr/local/bin
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
