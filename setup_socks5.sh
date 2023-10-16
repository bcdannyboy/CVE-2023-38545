#!/bin/bash

# Install Dante Server
sudo apt update
sudo apt install -y dante-server

# Backup original config
sudo cp /etc/danted.conf /etc/danted.conf.bak

# Get the active network interface
INTERFACE=$(ip route | grep default | awk '{print $5}')

# Create new Dante config without authentication
echo "logoutput: /var/log/danted.log
user.privileged: root
user.unprivileged: nobody

# The listening network interface or address.
internal: 0.0.0.0 port=1080

# The proxying network interface or address.
external: $INTERFACE

method: none  # No authentication

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}
pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    command: bind connect udpassociate
    log: error
    method: none  # No authentication
}" | sudo tee /etc/danted.conf

# Restart Dante server
sudo systemctl restart danted

# Create log file and set permissions
sudo touch /var/log/danted.log
sudo chmod 644 /var/log/danted.log

# Restart Dante server again
sudo systemctl restart danted

echo "Dante SOCKS5 proxy is set up on port 1080 without authentication."
