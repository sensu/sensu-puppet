#!/bin/bash

# setup module dependencies
puppet module install puppet/rabbitmq

# install dependencies for sensu
yum -y install redis jq nagios-plugins-ntp
systemctl start redis
systemctl enable redis

# run puppet
puppet apply /vagrant/tests/rabbitmq.pp
puppet apply /vagrant/tests/sensu-server.pp
puppet apply /vagrant/tests/uchiwa.pp
