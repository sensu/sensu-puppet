#!/bin/bash

# install test software for sensu
yum -y install jq nagios-plugins-ntp

# run puppet
puppet apply /vagrant/tests/sensu-server-cluster.pp
