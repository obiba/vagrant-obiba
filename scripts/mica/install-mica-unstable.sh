#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

cd /tmp

# download lastest distribution from jenkins

# output: >mica_distribution-7.x-9.0-b3083.tar.gz
MICA_UNSTABLE=`wget -q -O - http://ci.obiba.org/view/Mica/job/Mica/ws/target/ | grep -o ">mica[^\'\"]*.tar.gz"`

# remove first character
MICA_UNSTABLE=${MICA_UNSTABLE:1}

RELEASE_URL=http://ci.obiba.org/view/Mica/job/Mica/ws/target/$MICA_UNSTABLE
echo "Download $RELEASE_URL"

wget -q $RELEASE_URL
tar xzf $MICA_UNSTABLE

sudo cp -r $MICA_UNSTABLE /var/www/mica
sudo chown -R www-data:www-data /var/www/mica

# load preinstalled database
mysql -u $MYSQL_MICA_USER --password='$MYSQL_MICA_PWD' mica < $VAGRANT_DATA/mica-dev/mica-dev.sql

# copy mica settings.php
sudo cp $VAGRANT_DATA/mica/settings.php /var/www/mica/sites/default/

# Tools
sudo apt-get -y install make unzip daemon

# Java7 install
sudo apt-get -y install java7-runtime
sudo update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java

# SolR setup
sudo mkdir -p /usr/share/mica-solr
sudo mkdir -p /etc/mica-solr
sudo mkdir -p /var/lib/mica-solr

# get source code
wget -q https://github.com/obiba/mica/archive/master.zip
unzip master.zip
cd /tmp/mica-master/src/main/deb/mica-solr/var/lib/mica-solr-installer
sudo make mica-solr-install-prepare
sudo make solr-install-setup
sudo cp /tmp/$MICA_UNSTABLE/profiles/mica_distribution/modules/search_api_solr/solr-conf/4.x/* /usr/share/mica-solr/solr/collection1/conf/
sudo make solr-install-finish
sudo cp /tmp/mica-master/src/main/deb/mica-solr/debian/init.d /etc/init.d/mica-solr
sudo chmod +x /etc/init.d/mica-solr
sudo update-rc.d mica-solr defaults
sudo service mica-solr start

# Clean temp files
rm -rf /tmp/$MICA_UNSTABLE