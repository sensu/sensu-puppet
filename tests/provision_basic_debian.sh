#!/bin/bash

# using this instead of "rpm -Uvh" to resolve dependencies
function deb_install() {
    package=$(echo $1 | awk -F "/" '{print $NF}')
    wget --quiet $1
    dpkg -i ./$package
    rm -f $package
}

export DEBIAN_FRONTEND=noninteractive

if [ -f /etc/lsb-release ]; then
  # ubuntu
  . /etc/lsb-release
  CODENAME=$DISTRIB_CODENAME
else
  # debian
  CODENAME=$(grep ^VERSION= /etc/os-release | awk -F \( '{print $2}' | awk -F \) '{print $1}')
  apt-get -y install apt-transport-https
  apt-get update
fi

# Debian 9 (stretch) complains about the dirmngr package missing.
if [ "${CODENAME}" == 'stretch' ]; then
  apt-get -y install dirmngr
fi

apt-key adv --fetch-keys http://apt.puppetlabs.com/DEB-GPG-KEY-puppet

apt-get -y install wget

# install and configure puppet
deb_install http://apt.puppetlabs.com/puppet5-release-${CODENAME}.deb
apt-get update
apt-get -y install puppet-agent
ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet

# suppress default warnings for deprecation
cat > /etc/puppetlabs/puppet/hiera.yaml <<EOF
---
version: 5
hierarchy:
  - name: Common
    path: common.yaml
defaults:
  data_hash: yaml_data
  datadir: hieradata
EOF

# use local sensu module
puppet resource file /etc/puppetlabs/code/environments/production/modules/sensu ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.25.1
puppet module install puppetlabs/apt --version 4.1.0
puppet module install puppet/trusted_ca --version 2.0.0

puppet resource host sensu-backend.example.com ensure=present ip=192.168.52.10

[ ! -d /etc/puppetlabs/puppet/ssl ] && mkdir /etc/puppetlabs/puppet/ssl
cp -r /vagrant/tests/ssl/* /etc/puppetlabs/puppet/ssl/
