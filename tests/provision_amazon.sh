#!/bin/bash

# using this instead of "rpm -Uvh" to resolve dependencies
function rpm_install() {
    package=$(echo $1 | awk -F "/" '{print $NF}')
    wget --quiet $1
    yum install -y ./$package
    rm -f $package
}

release=$(awk -F \: '{print $5}' /etc/system-release-cpe)

rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppet

yum install -y wget

# install and configure puppet
rpm -qa | grep -q puppet
if [ $? -ne 0 ]
then

    rpm_install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
    yum-config-manager --enable epel >/dev/null 2>&1
    yum-config-manager --setopt="puppetlabs-pc1.priority=1" --save >/dev/null 2>&1

    yum -y install puppet-agent
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

fi

# use local sensu module
puppet resource file /etc/puppetlabs/code/environments/production/modules/sensu ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.24.0
puppet module install puppetlabs/apt --version 4.1.0
puppet module install lwf-remote_file --version 1.1.3
puppet module install puppetlabs/powershell --version 2.1.0

# install dependencies for sensu
yum -y install rubygems rubygem-json
