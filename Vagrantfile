# -*- mode: ruby -*-
# vi: set ft=ruby :

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
    server.vm.network :private_network, ip: "192.168.56.10"
    server.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    server.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    server.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    server.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    server.vm.provision :shell, :path => "tests/provision_server.sh"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
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
    client.vm.provision :shell, :inline => 'iex "puppet apply -v C:/vagrant/tests/sensu-client-windows.pp"'
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

  # This system is meant to be started without 'sensu-server' running.
  config.vm.define "sensu-server-enterprise", autostart: false do |server|
    server.vm.box = "centos/7"
    server.vm.hostname = 'sensu-server.example.com'
    server.vm.network :private_network, ip: "192.168.56.10"
    server.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    server.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    server.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    server.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    server.vm.provision :shell, :path => "tests/provision_enterprise_server.sh"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
  end

  # This system is meant to be started without 'sensu-server' running.
  config.vm.define "sensu-server-puppet5", autostart: false do |server|
    server.vm.box = "centos/7"
    server.vm.hostname = 'sensu-server.example.com'
    server.vm.network :private_network, ip: "192.168.56.10"
    server.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    server.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    server.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    server.vm.provision :shell, :path => "tests/provision_basic_el_puppet5.sh"
    server.vm.provision :shell, :path => "tests/provision_server.sh"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
  end
end
