#!/bin/bash

# Stop Dante server
sudo systemctl stop danted

# Remove Dante package
sudo apt remove --purge -y dante-server

# Restore original config
if [ -f /etc/danted.conf.bak ]; then
    sudo mv /etc/danted.conf.bak /etc/danted.conf
fi

# Remove log file
sudo rm -f /var/log/danted.log

echo "Dante SOCKS5 proxy has been removed."
