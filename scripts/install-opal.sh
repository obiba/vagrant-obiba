#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

if [ $(grep -c '^deb http://pkg.obiba.org stable/' /etc/apt/sources.list) -eq 0 ];
then
	wget -q -O - http://pkg.obiba.org/obiba.org.key | apt-key add -
	sudo sh -c 'echo "deb http://pkg.obiba.org stable/" >> /etc/apt/sources.list'
fi

if [ $(grep -c '^deb http://cran.rstudio.com/bin/linux/ubuntu precise/' /etc/apt/sources.list) -eq 0 ];
then
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
	sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" >> /etc/apt/sources.list'
fi

sudo apt-get update

if [ ! -d /etc/mysql ];
then
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
	sudo apt-get -y install mysql-server 
fi

sudo debconf-set-selections <<< 'opal opal-server/admin_password password password'
sudo debconf-set-selections <<< 'opal opal-server/admin_password_again password password'
sudo apt-get -y install opal 
sudo apt-get -y install opal-python-client

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
if [ -d $VAGRANT_DATA/opal/conf ];
then
	sudo cp -r $VAGRANT_DATA/opal/conf/* /etc/opal
	sudo chown -R opal:adm /etc/opal
	sudo service opal restart
fi

if [ -d $VAGRANT_DATA/opal/fs ];
then
	sudo cp -r $VAGRANT_DATA/opal/fs/* /var/lib/opal/fs
	sudo chown -R opal:nogroup /var/lib/opal/fs
fi

# R install
sudo apt-get -y install r-base r-cran-rserve

# R server setup
if [ -f $VAGRANT_DATA/r/rserve ];
then
	sudo adduser --system --home /var/lib/rserve --disabled-password rserve
	sudo cp $VAGRANT_DATA/r/rserve /etc/init.d
	sudo chmod +x /etc/init.d/rserve
	sudo update-rc.d rserve defaults
	sudo service rserve start
fi

# R studio setup
wget http://download2.rstudio.org/$RSTUDIO
sudo apt-get -y install libssl0.9.8
sudo dpkg -i $RSTUDIO
rm $RSTUDIO

sudo cp /usr/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d
sudo update-rc.d rstudio-server defaults

# Opal R client
sudo apt-get -y install libcurl4-openssl-dev
if [ -f $VAGRANT_DATA/r/install-opal-r-client.R ];
then
	sudo Rscript $VAGRANT_DATA/r/install-opal-r-client.R
	sudo service rserve stop
	sudo service rserve start
	sudo Rscript $VAGRANT_DATA/r/install-opal-r-server.R
fi

# TODO install DataSHIELD packages (needs to restart rserve)

# Add default datashield user
sudo adduser --disabled-password --gecos "" datashield
echo "datashield:datashield4ever" | sudo chpasswd
