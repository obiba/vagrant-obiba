#!/bin/sh

if [ $(grep -c '^deb http://pkg.obiba.org stable/' /etc/apt/sources.list) -eq 0 ];
then
	wget -q -O - http://pkg.obiba.org/obiba.org.key | apt-key add -
	sudo sh -c 'echo "deb http://pkg.obiba.org stable/" >> /etc/apt/sources.list'
fi
