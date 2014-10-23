#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

if [ $(grep -c '^deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' /etc/apt/sources.list) -eq 0 ];
then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
fi

add-apt-repository -y ppa:webupd8team/java

sudo apt-get update

# MongoDB install
sudo apt-get install -y mongodb-org

# Java8 install
echo oracle-java8-installer	shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
apt-get install -y oracle-java8-installer
sudo update-alternatives --set java /usr/lib/jvm/java-8-oracle/jre/bin/java

# Opal install
echo opal opal-server/admin_password select $OPAL_PWD | sudo debconf-set-selections
echo opal opal-server/admin_password_again select $OPAL_PWD | sudo debconf-set-selections
sudo apt-get install -y opal
sudo apt-get install -y opal-python-client

sleep 30

# Add databases in Opal at the end of the VM setup so we are sure that Opal is running
echo "Create Opal databases"
opal rest -o https://localhost:8443 -u administrator -p $OPAL_PWD -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/idsdb.json
opal rest -o https://localhost:8443 -u administrator -p $OPAL_PWD -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/mongodb.json

# Mica server install
echo mica-server mica-server/admin_password select $OPAL_PWD | sudo debconf-set-selections
echo mica-server mica-server/admin_password_again select $OPAL_PWD | sudo debconf-set-selections
sudo apt-get install -y mica-server
sudo apt-get install -y mica-python-client

# Seed with some studies
wget https://raw.githubusercontent.com/obiba/mica-server/master/mica-core/src/test/resources/seed/studies.json
sudo mkdir -p /var/lib/mica-server/seed/in
sudo mv studies.json /var/lib/mica-server/seed/in
sudo chown -R mica-server:nogroup /var/lib/mica-server/seed

