#!/bin/bash

# using this instead of "rpm -Uvh" to resolve dependencies
function deb_install() {
    package=$(echo $1 | awk -F "/" '{print $NF}')
    wget --quiet $1
    dpkg -i ./$package
    rm -f $package
}

export DEBIAN_FRONTEND=noninteractive

. /etc/lsb-release

apt-key adv --fetch-keys http://apt.puppetlabs.com/DEB-GPG-KEY-puppet

apt-get -y install wget

# install and configure puppet
deb_install http://apt.puppetlabs.com/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb
apt-get update
apt-get -y install puppet-agent
ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet

# suppress default warings for deprecation
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
puppet module install puppetlabs/stdlib --version 4.16.0
puppet module install puppetlabs/apt --version 4.1.0
puppet module install lwf-remote_file --version 1.1.3
puppet module install puppetlabs/powershell --version 2.1.0

# install dependencies for sensu
apt-get -y install ruby-json
