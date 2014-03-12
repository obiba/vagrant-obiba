#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

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
sudo cp $VAGRANT_DATA/mysql/my.cnf /etc/mysql
sudo service mysql restart

# Java7 install
sudo apt-get -y install java7-runtime
sudo update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java

# execute this after Java installation so we are sure MySQL is running
echo "CREATE DATABASE opal_data CHARACTER SET utf8 COLLATE utf8_bin" | mysql -uroot -prootpass
echo "CREATE DATABASE opal_ids CHARACTER SET utf8 COLLATE utf8_bin" | mysql -uroot -prootpass
echo "CREATE USER 'opaluser'@'localhost' IDENTIFIED BY 'opalpass'" | mysql -uroot -prootpass
echo "GRANT ALL ON opal_data.* TO 'opaluser'@'localhost'" | mysql -uroot -prootpass
echo "GRANT ALL ON opal_ids.* TO 'opaluser'@'localhost'" | mysql -uroot -prootpass
echo "FLUSH PRIVILEGES" | mysql -uroot -prootpass

# Opal install
sudo debconf-set-selections <<< 'opal opal-server/admin_password password password'
sudo debconf-set-selections <<< 'opal opal-server/admin_password_again password password'
sudo apt-get -y install opal
sudo apt-get -y install opal-python-client

# R dependencies
sudo apt-get install -y opal-rserver
sudo service rserver restart

# Opal R client
sudo Rscript $VAGRANT_DATA/r/install-opal-r-client.R
sudo service rserve restart
sudo Rscript $VAGRANT_DATA/r/install-opal-r-server.R

# R studio
wget -q http://download2.rstudio.org/$RSTUDIO
sudo apt-get -y install libssl0.9.8
sudo dpkg -i $RSTUDIO
rm $RSTUDIO

sudo cp /usr/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d
sudo update-rc.d rstudio-server defaults

# Add default datashield user
sudo adduser --disabled-password --gecos "" datashield
echo "datashield:datashield4ever" | sudo chpasswd

# create databases in Opal at the end of the VM setup so we are sure that Opal is running
echo "Create Opal databases"
opal rest -o http://localhost:8080 -u administrator -p password -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/idsdb.json
opal rest -o http://localhost:8080 -u administrator -p password -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/sqldb.json
opal rest -o http://localhost:8080 -u administrator -p password -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/mongodb.json
