#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

if [ $(grep -c '^deb http://pkg.obiba.org unstable/' /etc/apt/sources.list) -eq 0 ];
then
	wget -q -O - http://pkg.obiba.org/obiba.org.key | sudo apt-key add -
	sudo sh -c 'echo "deb http://pkg.obiba.org unstable/" >> /etc/apt/sources.list'
fi

if [ $(grep -c '^deb http://cran.rstudio.com/bin/linux/ubuntu precise/' /etc/apt/sources.list) -eq 0 ];
then
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
	sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" >> /etc/apt/sources.list'
fi

if [ $(grep -c '^deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' /etc/apt/sources.list) -eq 0 ];
then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
fi

sudo apt-get update

# MongoDB install
sudo apt-get install mongodb-10gen

# MySQL install
if [ ! -d /etc/mysql ];
then
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
	sudo apt-get -y install mysql-server 
fi

# Java7 install
sudo apt-get -y install java7-runtime
sudo update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java

# R dependencies
sudo apt-get install -y r-cran-rserve daemon
wget -q http://pkg.obiba.org/stable/rserver-admin-1.0.0-b20140227113905_all.deb
sudo dpkg -i rserver-admin-1.0.0-b20140227113905_all.deb

# Opal install
sudo debconf-set-selections <<< 'opal opal-server/admin_password password password'
sudo debconf-set-selections <<< 'opal opal-server/admin_password_again password password'
sudo apt-get -y install opal 

# Opal database setup
if [ -f $VAGRANT_DATA/mysql/my.cnf ];
then
	sudo cp $VAGRANT_DATA/mysql/my.cnf /etc/mysql
	sudo service mysql restart
fi

echo "CREATE DATABASE opal_data CHARACTER SET utf8" | mysql -uroot -prootpass
echo "CREATE DATABASE opal_ids CHARACTER SET utf8" | mysql -uroot -prootpass
echo "CREATE USER 'opaluser'@'localhost' IDENTIFIED BY 'opalpass'" | mysql -uroot -prootpass
echo "GRANT ALL ON opal_data.* TO 'opaluser'@'localhost'" | mysql -uroot -prootpass
echo "GRANT ALL ON opal_ids.* TO 'opaluser'@'localhost'" | mysql -uroot -prootpass
echo "FLUSH PRIVILEGES" | mysql -uroot -prootpass

if [ -f $VAGRANT_DATA/mysql/opal_data-initial.sql ];
then
	mysql -uroot -prootpass opal_data < $VAGRANT_DATA/mysql/opal_data-initial.sql
fi

if [ -f $VAGRANT_DATA/mysql/opal_ids-initial.sql ];
then
	mysql -uroot -prootpass opal_ids < $VAGRANT_DATA/mysql/opal_ids-initial.sql
fi

# Opal configuration setup
sleep 20
sudo apt-get -y install unzip
cd /tmp
wget -q https://github.com/obiba/opal-home/archive/master.zip
unzip master.zip
sudo cp -r /tmp/opal-home-master/fs/* /var/lib/opal/fs
sudo chown -R opal:nogroup /var/lib/opal/fs
rm -rf /tmp/opal-home-master
rm -rf /tmp/master.zip

sudo apt-get -y install opal-python-client

if [ -f $VAGRANT_DATA/opal-dev/idsdb.json ];
then
	opal rest -o http://localhost:8080 -u administrator -p password -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal-dev/idsdb.json
fi

if [ -f $VAGRANT_DATA/opal-dev/sqldb.json ];
then
	opal rest -o http://localhost:8080 -u administrator -p password -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal-dev/sqldb.json
fi

if [ -f $VAGRANT_DATA/opal-dev/mongodb.json ];
then
	opal rest -o http://localhost:8080 -u administrator -p password -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal-dev/mongodb.json
fi