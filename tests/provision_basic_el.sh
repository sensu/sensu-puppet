#!/bin/bash

# using this instead of "rpm -Uvh" to resolve dependencies
function rpm_install() {
    package=$(echo $1 | awk -F "/" '{print $NF}')
    wget --quiet $1
    yum install -y ./$package
    rm -f $package
}

release=$(awk -F \: '{print $5}' /etc/system-release-cpe)

rpm --import http://download-ib01.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${release}
rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppet
rpm --import http://vault.centos.org/RPM-GPG-KEY-CentOS-${release}

yum install -y wget

# install and configure puppet
rpm -qa | grep -q puppet
if [ $? -ne 0 ]
then

    rpm_install http://yum.puppetlabs.com/puppet5/puppet5-release-el-${release}.noarch.rpm
    yum -y install puppet-agent
    ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet
fi

# use local sensu module
puppet resource file /etc/puppetlabs/code/environments/production/modules/sensu ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.24.0
puppet module install puppetlabs/apt --version 4.1.0
puppet module install lwf-remote_file --version 1.1.3

# install EPEL repos for required dependencies
rpm_install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${release}.noarch.rpm

# install dependencies for sensu
yum -y install rubygems rubygem-json
