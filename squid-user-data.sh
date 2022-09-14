#!/bin/bash
#
# DO NOT EDIT BELOW THIS LINE

sudo snap start amazon-ssm-agent
sudo apt-get update
sudo apt-get install squid -y

wget https://raw.githubusercontent.com/richardshaw1/config-files/main/squid.conf -O /etc/squid/squid.conf

sudo systemctl start squid
