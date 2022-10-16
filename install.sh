#! /bin/bash

sudo mkdir -p /etc/tunnel/
sudo cp ./cn_rules.conf /etc/tunnel/
sudo chmod 755 /etc/tunnel
sudo chmod 644 /etc/tunnel/*

sudo cp ./tunnel.service /etc/systemd/system/

sudo chmod +x ./tunnel.sh
sudo cp ./tunnel.sh /usr/local/bin/tunnel

hash -r
