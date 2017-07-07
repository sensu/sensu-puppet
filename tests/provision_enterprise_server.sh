#!/bin/bash

if [ -z "${FACTER_SE_USER:-}" ]; then
  echo "ERROR: You must export FACTER_SE_USER and FACTER_SE_PASS" >&2
  echo "ERROR: In the shell that executes vagrant up" >&2
  exit 1
fi
echo "FACTER_SE_USER=$FACTER_SE_USER"

# setup module dependencies
puppet module install puppetlabs/rabbitmq

# install dependencies for sensu
yum -y install redis jq nagios-plugins-ntp
systemctl start redis
systemctl enable redis

# run puppet
puppet apply /vagrant/tests/rabbitmq.pp
puppet apply /vagrant/tests/sensu-server-enterprise.pp
puppet apply /vagrant/tests/uchiwa.pp
