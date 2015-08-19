# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder "../", "/vagrant_data" # Mount directory up a level so puppet module list can find modules
  config.vm.synced_folder ".", "/vagrant"
  #config.vm.private_networkork "forwarded_port", guest: 8080, host: 8080
  # config.vm.network :private_network, type: "dhcp"


  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.define "sensu-server", primary: true, autostart: true do |server|
    server.vm.box = "ubuntu/trusty64"
    server.vm.hostname = 'sensu-server.example.com'
    server.vm.network :private_network, ip: "192.168.56.10"
    server.vm.provision :shell, :path => "tests/provision_server.sh"
    server.vm.provision :puppet, :manifests_path => ["vm","/vagrant/tests"], :manifest_file => "rabbitmq.pp", :options => "--hiera_config /etc/hiera.yaml"
    server.vm.provision :puppet, :manifests_path => ["vm","/vagrant/tests"], :manifest_file => "sensu-server.pp", :options => "--hiera_config /etc/hiera.yaml"
    server.vm.provision :puppet, :manifests_path => ["vm","/vagrant/tests"], :manifest_file => "uchiwa.pp", :options => "--hiera_config /etc/hiera.yaml"
    server.vm.provision :shell, :path => "tests/rabbitmq.sh"
  end

  config.vm.define "sensu-client", autostart: true do |client|
    client.vm.box = "ubuntu/trusty64"
    client.vm.hostname = 'sensu-client.example.com'
    client.vm.network  :private_network, ip: "192.168.56.11"
    client.vm.provision :shell, :path => "tests/provision_client.sh"
    client.vm.provision :puppet, :manifests_path => ["vm","/vagrant/tests"], :manifest_file => "sensu-client.pp", :options => "--hiera_config /etc/hiera.yaml"
  end

end
