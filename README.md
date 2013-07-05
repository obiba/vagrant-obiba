Vagrant OBiBa
=============

Vagrant files for OBiBa stack.

## Prerequisites

* [Vagrant](http://www.vagrantup.com/)
* [VirtualBox (4.1)](https://www.virtualbox.org/)

## Usage

Example on the VirtualBox VM running Opal:

	cd opal
	vagrant up
	# then connect to https://localhost:8843

Example on the VirtualBox VM running Opal and Mica:

	cd opal-mica
	vagrant up
	# then connect to opal on https://localhost:8843
	# or connect to mica on http://localhost:8800

Example on the VirtualBox VM running Mica:

	cd mica
	vagrant up
	# then connect to mica on http://localhost:8800

