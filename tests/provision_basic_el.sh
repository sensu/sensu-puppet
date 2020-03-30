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

    rpm_install http://yum.puppetlabs.com/puppet5-release-el-${release}.noarch.rpm
    yum -y install puppet-agent
    ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet
fi

# use local sensu module
puppet resource file /etc/puppetlabs/code/environments/production/modules/sensu ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version ">= 5.1.0 < 7.0.0"
puppet module install richardc-datacat --version ">= 0.6.2 < 2.0.0"

puppet resource host sensu-backend.example.com ensure=present ip=192.168.52.10 host_aliases=sensu-backend

name=$(hostname -s)
if [[ "${name}" == *"agent" ]]; then
  puppet config set --section main certname sensu-agent
elif [[ "${name}" == "sensu-backend" ]]; then
  puppet config set --section main certname sensu-backend
elif [[ "${name}" == *"peer1" ]]; then
  puppet config set --section main certname sensu-backend1
elif [[ "${name}" == *"peer2" ]]; then
  puppet config set --section main certname sensu-backend2
fi

[ ! -d /etc/puppetlabs/puppet/ssl ] && mkdir /etc/puppetlabs/puppet/ssl
cp -r /vagrant/tests/ssl/* /etc/puppetlabs/puppet/ssl/
