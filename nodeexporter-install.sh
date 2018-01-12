sudo useradd --no-create-home --shell /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.15.2/node_exporter-0.15.2.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
tar -xvzf /tmp/node_exporter.tar.gz
sudo mv node_exporter-0.15.2.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-0.15.2.linux-amd64

sudo bash -c 'cat >> /etc/systemd/system/node_exporter.service' <<EOT
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload # load config
sudo systemctl start node_exporter # start now
sudo systemctl enable node_exporter # start on boot
sudo systemctl status node_exporter