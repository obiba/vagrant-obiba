#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

if [ $(grep -c '^deb http://pkg.obiba.org stable/' /etc/apt/sources.list) -eq 0 ];
then
	wget -q -O - http://pkg.obiba.org/obiba.org.key | sudo apt-key add -
	sudo sh -c 'echo "deb http://pkg.obiba.org stable/" >> /etc/apt/sources.list'
fi

sudo apt-get update

# all these config will be overridden when copying settings.php
sudo debconf-set-selections <<< 'mica mica/dbconfig-install boolean false'
sudo debconf-set-selections <<< 'mica mica/database-type select mysql'
sudo debconf-set-selections <<< 'mica mica/mysql/admin-pass password password'
sudo debconf-set-selections <<< 'mica mica/mysql/app-pass password password'
sudo debconf-set-selections <<< 'mica mica/password-confirm password password'

sudo apt-get -y install mica

# load preinstalled database
mysql -u $MYSQL_MICA_USER --password=$MYSQL_MICA_PWD mica < $VAGRANT_DATA/mica/mica.sql

# copy mica settings.php
sudo cp $VAGRANT_DATA/mica/settings.php /usr/share/mica/sites/default/
sudo sed -i 's/@MYSQL_MICA_USER@/'$MYSQL_MICA_USER'/' /usr/share/mica/sites/default/settings.php
sudo sed -i 's/@MYSQL_MICA_PWD@/'$MYSQL_MICA_PWD'/' /usr/share/mica/sites/default/settings.php

# Add mica-solr service to boot
sudo update-rc.d mica-solr defaults
sudo service mica-solr restart
