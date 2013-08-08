#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

sudo apt-get -y install git
sudo apt-get -y install make
sudo apt-get -y install unzip
sudo apt-get -y install openjdk-7-jre
sudo apt-get -y install php5-curl

cd /tmp

git clone https://github.com/obiba/mica.git
cd mica
make install-packaging-dependencies 
make install-drush
mkdir target
make install-lessc
make dev
cp -r target/mica-dev /var/www/
chown -R www-data:www-data /var/www/mica-dev

if [ ! -d /etc/mysql ];
then
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
	sudo apt-get -y install mysql-server 
fi

# load preinstalled database
if [ -f $VAGRANT_DATA/mica_dev/mica_dev.sql ];
then
	echo "CREATE USER 'mica'@'localhost' IDENTIFIED BY 'pass246'" | mysql -uroot -prootpass
	echo "CREATE DATABASE mica" | mysql -uroot -prootpass
	echo "GRANT ALL ON mica.* TO 'mica'@'localhost'" | mysql -uroot -prootpass
	sudo mysql -u mica --password='pass246' mica < $VAGRANT_DATA/mica_dev/mica_dev.sql
fi

if [ -f $VAGRANT_DATA/mica/settings.php ];
then
	sudo cp $VAGRANT_DATA/mica/settings.php /var/www/mica-dev/sites/default/
fi

if [ -f $VAGRANT_DATA/mica/php.ini ];
then
	sudo cp $VAGRANT_DATA/mica/php.ini /etc/php5/apache2/	
fi

# install mica-solr as a daemon
sudo apt-get install daemon
sudo mkdir -p /usr/share/mica-solr
sudo mkdir -p /etc/mica-solr
sudo mkdir -p /var/lib/mica-solr
cd /tmp/mica/src/main/deb/mica-solr/var/lib/mica-solr-installer
sudo make mica-solr-install-prepare
sudo make solr-install-setup
sudo cp /tmp/mica/target/mica-dev/profiles/mica_distribution/modules/search_api_solr/solr-conf/4.x/* /usr/share/mica-solr/solr/collection1/conf/
sudo make solr-install-finish
sudo cp /tmp/mica/src/main/deb/mica-solr/debian/init.d /etc/init.d/mica-solr
sudo chmod +x /etc/init.d/mica-solr
sudo update-rc.d mica-solr defaults
sudo service mica-solr start
