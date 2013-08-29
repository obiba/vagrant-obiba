Vagrant OBiBa
=============

Vagrant files for OBiBa stack.

## Vagrant VirtualBox

### Prerequisites

* [Vagrant](http://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/) (version 4.1.x or 4.2.10 according to this [issue](https://github.com/mitchellh/vagrant/issues/1847))

### Opal

Example on the VirtualBox VM running Opal:

	cd vagrant-virtualbox/opal
	vagrant up

Then connect to:
* opal on [https://localhost:8843](https://localhost:8843)
* opal on `sftp -P 8822 administrator@localhost`
* RStudio on [https://localhost:8887](https://localhost:8887)

### Mica

Example on the VirtualBox VM running Mica:

	cd vagrant-virtualbox/mica
	vagrant up

Then connect to:
* mica on [http://localhost:8800/mica](http://localhost:8800/mica)

### Opal + Mica

Example on the VirtualBox VM running Opal and Mica:

	cd vagrant-virtualbox/opal-mica
	vagrant up

Then connect to:
* mica on [http://localhost:8800/mica](http://localhost:8800/mica)
* opal on [https://localhost:8843](https://localhost:8843)
* opal on `sftp -P 8822 administrator@localhost`
* RStudio on [https://localhost:8887](https://localhost:8887)

## Vagrant AWS

### Prerequisites

* [Vagrant](http://www.vagrantup.com/)
* [Vagrant AWS](https://github.com/mitchellh/vagrant-aws): `vagrant plugin install vagrant-aws`
* a [AWS account](https://aws.amazon.com/)

### Opal

Example of a AWS instance running Opal:

	cd vagrant-aws/opal
	# edit AWS credentials
	vagrant up --provider=aws

Then connect to:
* opal on https://aws-instance:8443
* opal on `sftp -P 8022 administrator@aws-instance`
* RStudio on https://aws-instance:8787

### Mica

When launching a mica_dev vagrant, visit [http://localhost:8800/mica/update.php](http://localhost:8800/mica/update.php) 
to make sure that the database is up-to-date with possibly new/updated modules.

Example of a AWS instance running Mica:

	cd vagrant-aws/mica
	# edit AWS credentials
	vagrant up --provider=aws

Then connect to:
* mica on http://aws-instance/mica

### Opal + Mica

Example of a AWS instance running Opal and Mica:

	cd vagrant-aws/opal-mica
	# edit AWS credentials
	vagrant up --provider=aws

Then connect to:
* mica on http://aws-instance/mica
* opal on https://aws-instance:8443
* opal on `sftp -P 8022 administrator@aws-instance`
* RStudio on https://aws-instance:8787 
