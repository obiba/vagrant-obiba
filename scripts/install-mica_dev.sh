#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

sudo apt-get -y install git
sudo apt-get -y install make
sudo apt-get -y install unzip
sudo apt-get -y install openjdk-7-jre

git clone https://github.com/obiba/mica.git
cd mica
make install-packaging-dependencies 
make install-drush
mkdir target
make install-lessc

make dev

cd /home/vagrant/mica
mkdir -p solr
cd solr
wget -q http://mirror.csclub.uwaterloo.ca/apache/lucene/solr/4.2.1/solr-4.2.1.tgz
tar -zxf solr-4.2.1.tgz
cp /home/vagrant/mica/target/mica-dev/profiles/mica_distribution/modules/search_api_solr/solr-conf/4.x/* solr-4.2.1/example/solr/collection1/conf
rm solr-4.2.1.tgz

cd /home/vagrant/mica
cp -r target/mica-dev /var/www/

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

sudo chown -R vagrant /home/vagrant/mica

#nohup make start-solr&