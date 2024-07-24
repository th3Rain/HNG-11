#!/bin/bash

# Install necessary dependencies for the installation script
sudo apt update
sudo apt install -y iproute2 docker.io finger nginx logrotate

# Check if each required command is available
commands=("ss" "docker" "finger" "nginx" "journalctl")

for cmd in "${commands[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd command is not installed."
        exit 1
    fi
done

# Copy devopsfetch script to /usr/local/bin
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch
sudo chmod +x /usr/local/bin/devopsfetch

# Create systemd service
sudo bash -c 'cat <<EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=Devopsfetch Service

[Service]
ExecStart=/usr/local/bin/devopsfetch -t "starttime 00:00:00" "stoptime 23:59:59"
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Create systemd timer
sudo bash -c 'cat <<EOF > /etc/systemd/system/devopsfetch.timer
[Unit]
Description=Run devopsfetch every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF'

# Reload systemd and start the timer
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.timer
sudo systemctl start devopsfetch.timer

# Configure log rotation
sudo bash -c 'cat <<EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl restart devops