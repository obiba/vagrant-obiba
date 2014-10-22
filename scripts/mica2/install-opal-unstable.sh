#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

if [ $(grep -c '^deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' /etc/apt/sources.list) -eq 0 ];
then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
fi

sudo apt-get update

# MongoDB install
sudo apt-get install -y mongodb-org

# Java8 install
add-apt-repository -y ppa:webupd8team/java
apt-get install -y oracle-java8-installer
sudo update-alternatives --set java /usr/lib/jvm/java-8-oracle/jre/bin/java

# Opal install
echo opal opal-server/admin_password select $OPAL_PWD | debconf-set-selections
echo opal opal-server/admin_password_again select $OPAL_PWD | debconf-set-selections
sudo apt-get install -y opal
sudo apt-get install -y opal-python-client

sleep 30

# Add databases in Opal at the end of the VM setup so we are sure that Opal is running
echo "Create Opal databases"
opal rest -o https://localhost:8443 -u administrator -p $OPAL_PWD -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/idsdb.json
opal rest -o http://localhost:8443 -u administrator -p $OPAL_PWD -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/mongodb.json
