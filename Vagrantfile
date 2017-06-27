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
    server.vm.provision :shell, :path => "tests/provision_basic.sh"
    server.vm.provision :shell, :path => "tests/provision_server.sh"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
  end

  config.vm.define "sensu-client", autostart: true do |client|
    client.vm.box = "centos/7"
    client.vm.hostname = 'sensu-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.11"
    client.vm.provision :shell, :path => "tests/provision_basic.sh"
    client.vm.provision :shell, :path => "tests/provision_client.sh"
  end
end
