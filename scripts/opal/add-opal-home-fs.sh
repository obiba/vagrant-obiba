#!/bin/sh

# Download opal-home file system
sleep 20
sudo apt-get -y install unzip
cd /tmp
wget -q https://github.com/obiba/opal-home/archive/master.zip
unzip -q master.zip
sudo cp -r /tmp/opal-home-master/fs/* /var/lib/opal/fs
sudo chown -R opal:nogroup /var/lib/opal/fs
rm -rf /tmp/opal-home-master
rm -rf /tmp/master.zip
