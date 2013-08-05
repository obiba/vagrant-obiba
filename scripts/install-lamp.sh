#!/bin/bash

sudo apt-get update

# if mysql does not exist
if [ ! -d /etc/mysql ];
then
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
	sudo apt-get -y install mysql-server 
fi

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

	# Restart services
	sudo service apache2 restart
fi
