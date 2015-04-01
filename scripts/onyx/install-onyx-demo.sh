#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

sudo apt-get update

# MySQL install
if [ ! -d /etc/mysql ];
then
  echo mysql-server mysql-server/root_password select $MYSQL_ROOT_PWD | debconf-set-selections
  echo mysql-server mysql-server/root_password_again select $MYSQL_ROOT_PWD | debconf-set-selections
	sudo apt-get -y install mysql-server
fi
sudo cp $VAGRANT_DATA/mysql/my.cnf /etc/mysql
sudo service mysql restart

echo "CREATE DATABASE onyx CHARACTER SET utf8 COLLATE utf8_bin" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "CREATE USER '$MYSQL_ONYX_USER'@'localhost' IDENTIFIED BY '$MYSQL_ONYX_PWD'" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "GRANT ALL ON onyx.* TO '$MYSQL_ONYX_USER'@'localhost'" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "FLUSH PRIVILEGES" | mysql -uroot -p$MYSQL_ROOT_PWD

# Java and Jetty install
sudo apt-get install -y openjdk-6-jdk
sudo apt-get install -y jetty8
sed s/NO_START=1/NO_START=0/ /etc/default/jetty8 | sed s/#JAVA_HOME=/JAVA_HOME=\\/usr\\/lib\\/jvm\\/java-6-openjdk-amd64\\/jre/ > /tmp/jetty8
sudo mv /tmp/jetty8 /etc/default/jetty8

# Onyx demo install
mkdir -p onyx-demo
cd onyx-demo
wget -q http://ci.obiba.org/job/Onyx%20Demo/ws/target/onyx-demo.war
jar xf onyx-demo.war
rm onyx-demo.war
cp $VAGRANT_DATA/onyx/onyx-config.properties WEB-INF/config
cd ..
jar cf onyx-demo.war -C onyx-demo/ .
sudo mv onyx-demo.war /usr/share/jetty8/webapps
sudo chown jetty:adm /usr/share/jetty8/webapps/onyx-demo.war

sudo service jetty8 start