#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

sudo apt-get update

# MySQL install
if [ ! -d /etc/mysql ];
then
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
	sudo apt-get -y install mysql-server
fi
sudo cp $VAGRANT_DATA/mysql/my.cnf /etc/mysql
sudo service mysql restart

# if apache2 does no exist
if [ ! -d /etc/apache2 ];
then
	# Install Apache2
	sudo apt-get -y install apache2

	# Install PHP5 support
	sudo apt-get -y install make php5 libapache2-mod-php5 php-apc php5-mysql php5-dev php5-curl php5-gd

	# Install SSL tools
	#apt-get -y install ssl-cert

	# Install OpenSSL
	sudo apt-get -y install openssl

	# Install PHP pear
	sudo apt-get -y install php-pear

	# Install sendmail
	#apt-get -y install sendmail

	# Install CURL dev package
	sudo apt-get -y install libcurl4-openssl-dev

	# Install PECL HTTP (depends on php-pear, php5-dev, libcurl4-openssl-dev)
	printf "\n" | pecl install pecl_http

	# Enable PECL HTTP
	echo "extension=http.so" > /etc/php5/conf.d/http.ini

	# Enable mod_rewrite	
	sudo a2enmod rewrite

	# Enable SSL
	sudo a2enmod ssl

	# Add www-data to vagrant group
	sudo usermod -a -G vagrant www-data

	sudo cp $VAGRANT_DATA/mica/php.ini /etc/php5/apache2/

	# Restart services
	sudo service apache2 restart
fi

# execute this after Apache installation so we are sure MySQL is running
echo "CREATE DATABASE mica" | mysql -uroot -prootpass
echo "CREATE USER '$MYSQL_MICA_USER'@'localhost' IDENTIFIED BY '$MYSQL_MICA_PWD'" | mysql -uroot -prootpass
echo "GRANT ALL ON mica.* TO '$MYSQL_MICA_USER'@'localhost'" | mysql -uroot -prootpass
echo "FLUSH PRIVILEGES" | mysql -uroot -prootpass