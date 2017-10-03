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
puppet module install puppetlabs/stdlib --version 4.24.0
puppet module install puppetlabs/apt --version 4.1.0
puppet module install lwf-remote_file --version 1.1.3

# install dependencies for sensu
apt-get -y install ruby-json
