#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

if [ $(grep -c '^deb http://pkg.obiba.org stable/' /etc/apt/sources.list) -eq 0 ];
then
	wget -q -O - http://pkg.obiba.org/obiba.org.key | apt-key add -
	sudo sh -c 'echo "deb http://pkg.obiba.org stable/" >> /etc/apt/sources.list'
fi

sudo apt-get update

if [ ! -d /etc/mysql ];
then
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
	sudo apt-get -y install mysql-server 
fi

sudo debconf-set-selections <<< 'mica mica/dbconfig-install boolean false'
sudo debconf-set-selections <<< 'mica mica/database-type select mysql'
sudo debconf-set-selections <<< 'mica mica/mysql/admin-pass password rootpass'
sudo debconf-set-selections <<< 'mica mica/mysql/app-pass password pass246'
sudo debconf-set-selections <<< 'mica mica/password-confirm password pass246'

sudo apt-get -y install php5-curl
sudo apt-get -y install mica

# load preinstalled database
if [ -f $VAGRANT_DATA/mica/mica.sql ];
then
	sudo mysql -u mica --password='pass246' mica < $VAGRANT_DATA/mica/mica.sql
fi

if [ -f $VAGRANT_DATA/mica/settings.php ];
then
	sudo cp $VAGRANT_DATA/mica/settings.php /usr/share/mica/sites/default/
fi

if [ -f $VAGRANT_DATA/mica/php.ini ];
then
	sudo cp $VAGRANT_DATA/mica/php.ini /etc/php5/apache2/
	sudo service apache2 restart
fi

# Add mica-solr service to boot
sudo update-rc.d mica-solr defaults
sudo service mica-solr restart
