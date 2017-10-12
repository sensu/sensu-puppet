# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Environment variables may be used to control the behavior of the Vagrant VM's
# defined in this file.  This is intended as a special-purpose affordance and
# should not be necessary in normal situations.  In particular, sensu-server,
# sensu-server-enterprise, and sensu-server-puppet5 use the same IP address by
# default, creating a potential IP conflict.  If there is a need to run multiple
# server instances simultaneously, avoid the IP conflict by setting the
# ALTERNATE_IP environment variable:
#
#     ALTERNATE_IP=192.168.56.9 vagrant up sensu-server-enterprise
#
# NOTE: The client VM instances assume the server VM is accessible on the
# default IP address, therefore using an ALTERNATE_IP is not expected to behave
# well with client instances.
#
# When bringing up sensu-server-enterprise, the FACTER_SE_USER and
# FACTER_SE_PASS environment variables are required.  See the README for more
# information on how to configure sensu enterprise credentials.
if not Vagrant.has_plugin?('vagrant-vbguest')
  abort <<-EOM

vagrant plugin vagrant-vbguest is required.
https://github.com/dotless-de/vagrant-vbguest
To install the plugin, please run, 'vagrant plugin install vagrant-vbguest'.

  EOM
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.define "sensu-server", primary: true, autostart: true do |server|
    server.vm.box = "centos/7"
    server.vm.hostname = 'sensu-server.example.com'
    server.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.56.10'
    server.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    server.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    server.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    server.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    server.vm.provision :shell, :path => "tests/provision_server.sh"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
  end

  config.vm.define 'sensu-server-cluster', autostart: false do |server|
    server.vm.box = 'centos/7'
    server.vm.hostname = 'sensu-server.example.com'
    server.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.56.10'
    server.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    server.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    server.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    server.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    server.vm.provision :shell, :path => "tests/provision_server_cluster.sh"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
  end

  # This system is meant to be started without 'sensu-server' running.
  config.vm.define "sensu-server-puppet5", autostart: false do |server|
    server.vm.box = "centos/7"
    server.vm.hostname = 'sensu-server.example.com'
    server.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.56.10'
    server.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    server.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    server.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    server.vm.provision :shell, :path => "tests/provision_basic_el_puppet5.sh"
    server.vm.provision :shell, :path => "tests/provision_server.sh"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
  end

  # sensu-server-enterprise is meant to be started without 'sensu-server'
  # running.
  config.vm.define 'sensu-server-enterprise', autostart: false do |server|
    # Sensu Enterprise runs the JVM.  If the API does not start, look for OOM
    # errors in `/var/log/sensu/sensu-enterprise.log` as a possible cause.
    # NB: The JVM HEAP_SIZE is also configured down to 256m from 2048m in
    # `tests/sensu-server-enterprise.pp`
    server.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', '768']
    end
    server.vm.box = 'centos/7'
    server.vm.hostname = 'sensu-server.example.com'
    server.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.56.10'
    server.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    server.vm.network :forwarded_port, guest: 4568, host: 4568, auto_correct: true
    server.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    server.vm.provision :shell, :path => 'tests/provision_basic_el.sh'
    server.vm.provision :shell,
      :path => 'tests/provision_enterprise_server.sh',
      :env => {
        'FACTER_SE_USER' => ENV['FACTER_SE_USER'].to_s,
        'FACTER_SE_PASS' => ENV['FACTER_SE_PASS'].to_s,
      }
    server.vm.provision :shell, :path => 'tests/rabbitmq.sh'
  end

  config.vm.define "el7-client", autostart: true do |client|
    client.vm.box = "centos/7"
    client.vm.hostname = 'el7-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.11"
    client.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client.pp"
  end

  config.vm.define "el6-client", autostart: false do |client|
    client.vm.box = "centos/6"
    client.vm.hostname = 'el6-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.12"
    client.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client-sensu_gem.pp"
  end

  config.vm.define "ubuntu1604-client", autostart: false do |client|
    client.vm.box = "ubuntu/xenial64"
    client.vm.hostname = 'ubuntu1604-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.13"
    client.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client.pp"
  end

  config.vm.define "ubuntu1404-client", autostart: false do |client|
    client.vm.box = "ubuntu/trusty64"
    client.vm.hostname = 'ubuntu1404-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.14"
    client.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client-sensu_gem.pp"
  end

  config.vm.define "amazon201703-client", autostart: false do |client|
    client.vm.box = "mvbcoding/awslinux"
    client.vm.hostname = 'amazon201703-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.15"
    client.vm.provision :shell, :path => "tests/provision_amazon.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client-sensu_gem.pp"
  end

  config.vm.define "win2012r2-client", autostart: false do |client|
    client.vm.box = "opentable/win-2012r2-standard-amd64-nocm"
    client.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
    client.vm.hostname = 'win2012r2-client'
    client.vm.network  :private_network, ip: "192.168.56.15"
    client.vm.network "forwarded_port", host: 3389, guest: 3389, auto_correct: true
    # There are two basic power shell scripts.  The first installs Puppet, but
    # puppet is not in the PATH.  The second invokes a new shell which will have
    # Puppet in the PATH.
    #
    ## Install Puppet
    client.vm.provision :shell, :path => "tests/provision_basic_win.ps1"
    ## Symlink module into place, run puppet module install for puppet apply
    client.vm.provision :shell, :path => "tests/provision_basic_win.2.ps1"
    ## Install Sensu using the default Windows package provider (MSI)
    client.vm.provision :shell, :inline => 'iex "puppet apply -v C:/vagrant/tests/sensu-client-windows.pp"'
  end

  config.vm.define "win2012r2-client-chocolatey", autostart: false do |client|
    client.vm.box = "opentable/win-2012r2-standard-amd64-nocm"
    client.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
    client.vm.hostname = 'win2012r2-client'
    client.vm.network  :private_network, ip: "192.168.56.16"
    client.vm.network "forwarded_port", host: 3389, guest: 3389, auto_correct: true
    # There are two basic power shell scripts.  The first installs Puppet, but
    # puppet is not in the PATH.  The second invokes a new shell which will have
    # Puppet in the PATH.
    #
    ## Install Puppet
    client.vm.provision :shell, :path => "tests/provision_basic_win.ps1"
    ## Symlink module into place, run puppet module install for puppet apply
    client.vm.provision :shell, :path => "tests/provision_basic_win.2.ps1"
    ## Install Chocolatey
    client.vm.provision :shell, :inline => 'iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))'
    ## Install the chocolatey Puppet module to get the provider
    client.vm.provision :shell, :inline => 'iex "puppet module install chocolatey-chocolatey --version 1.2.6"'
    ## Install sensu using Chocolatey
    client.vm.provision :shell, :inline => 'iex "puppet apply -v C:/vagrant/tests/sensu-client-windows-chocolatey.pp"'
  end

  config.vm.define "debian8-client", autostart: false do |client|
    client.vm.box = "debian/jessie64"
    client.vm.hostname = 'debian8-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.17"
    client.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client.pp"
  end

  config.vm.define "debian7-client", autostart: false do |client|
    client.vm.box = "debian/wheezy64"
    client.vm.hostname = 'debian7-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.18"
    client.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client.pp"
  end

  # The rsync used to populate /vagrant will fail if the repo has the spec
  # fixtures created. To avoid, run `rake spec_clean` before `vagrant up`.
  config.vm.define "macos-client", autostart: false do |client|
    client.vm.box = "jhcook/macos-sierra"
    client.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
    client.vm.hostname = 'macos-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.19"
    client.vm.synced_folder ".", "/vagrant", type: "rsync", group: "wheel"
    client.vm.provision :shell, :path => "tests/provision_macos.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-client.pp"
    client.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--usb", "on"]
      vb.customize ["modifyvm", :id, "--usbehci", "off"]
    end
  end
end
