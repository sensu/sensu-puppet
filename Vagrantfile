# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Environment variables may be used to control the behavior of the Vagrant VM's
# defined in this file. This is intended as a special-purpose affordance and
# should not be necessary in normal situations. If there is a need to run
# multiple backend instances simultaneously, avoid the IP conflict by setting
# the ALTERNATE_IP environment variable:
#
#     ALTERNATE_IP=192.168.52.9 vagrant up sensu-backend
#
# NOTE: The agent VM instances assume the backend VM is accessible on the
# default IP address, therefore using an ALTERNATE_IP is not expected to behave
# well with agent instances.
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

  config.vm.define "sensu-backend", primary: true, autostart: true do |backend|
    backend.vm.box = "centos/7"
    backend.vm.hostname = 'sensu-backend.example.com'
    backend.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.52.10'
    backend.vm.network :forwarded_port, guest: 2380, host: 2380, auto_correct: true
    backend.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    backend.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true
    backend.vm.network :forwarded_port, guest: 8081, host: 8081, auto_correct: true
    backend.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    backend.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-backend.pp"
    backend.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define 'sensu-backend-cluster', autostart: false do |backend|
    backend.vm.box = 'centos/7'
    backend.vm.hostname = 'sensu-backend.example.com'
    backend.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.52.10'
    backend.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true
    backend.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
    backend.vm.network :forwarded_port, guest: 15672, host: 15672, auto_correct: true
    backend.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    backend.vm.provision :shell, :path => "tests/provision_backend_cluster.sh"
    backend.vm.provision :shell, :path => "tests/rabbitmq.sh"
    backend.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "el7-agent", autostart: true do |agent|
    agent.vm.box = "centos/7"
    agent.vm.hostname = 'el7-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.11"
    agent.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "el6-agent", autostart: false do |agent|
    agent.vm.box = "centos/6"
    agent.vm.hostname = 'el6-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.12"
    agent.vm.provision :shell, :path => "tests/provision_basic_el.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent-sensu_gem.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "ubuntu1604-agent", autostart: false do |agent|
    agent.vm.box = "ubuntu/xenial64"
    agent.vm.hostname = 'ubuntu1604-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.13"
    agent.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "ubuntu1404-agent", autostart: false do |agent|
    agent.vm.box = "ubuntu/trusty64"
    agent.vm.hostname = 'ubuntu1404-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.14"
    agent.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent-sensu_gem.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "amazon201703-agent", autostart: false do |agent|
    agent.vm.box = "mvbcoding/awslinux"
    agent.vm.hostname = 'amazon201703-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.15"
    agent.vm.provision :shell, :path => "tests/provision_amazon.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent-sensu_gem.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "win2012r2-agent", autostart: false do |agent|
    agent.vm.box = "opentable/win-2012r2-standard-amd64-nocm"
    agent.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
    agent.vm.hostname = 'win2012r2-agent'
    agent.vm.network  :private_network, ip: "192.168.52.15"
    agent.vm.network "forwarded_port", host: 3389, guest: 3389, auto_correct: true
    # There are two basic power shell scripts. The first installs Puppet, but
    # puppet is not in the PATH. The second invokes a new shell which will have
    # Puppet in the PATH.
    #
    ## Install Puppet
    agent.vm.provision :shell, :path => "tests/provision_basic_win.ps1"
    ## Symlink module into place, run puppet module install for puppet apply
    agent.vm.provision :shell, :path => "tests/provision_basic_win.2.ps1"
    ## Install Sensu using the default Windows package provider (MSI)
    agent.vm.provision :shell, :inline => 'iex "puppet apply -v C:/vagrant/tests/sensu-agent-windows.pp"'
    agent.vm.provision :shell, :inline => 'iex "facter --custom-dir=C:/vagrant/lib/facter sensu_version"'
  end

  config.vm.define "win2012r2-agent-chocolatey", autostart: false do |agent|
    agent.vm.box = "opentable/win-2012r2-standard-amd64-nocm"
    agent.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
    agent.vm.hostname = 'win2012r2-agent'
    agent.vm.network  :private_network, ip: "192.168.52.16"
    agent.vm.network "forwarded_port", host: 3389, guest: 3389, auto_correct: true
    # There are two basic power shell scripts. The first installs Puppet, but
    # puppet is not in the PATH. The second invokes a new shell which will have
    # Puppet in the PATH.
    #
    ## Install Puppet
    agent.vm.provision :shell, :path => "tests/provision_basic_win.ps1"
    ## Symlink module into place, run puppet module install for puppet apply
    agent.vm.provision :shell, :path => "tests/provision_basic_win.2.ps1"
    ## Install Chocolatey
    agent.vm.provision :shell, :inline => 'iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))'
    ## Install the chocolatey Puppet module to get the provider
    agent.vm.provision :shell, :inline => 'iex "puppet module install chocolatey-chocolatey --version 1.2.6"'
    ## Install sensu using Chocolatey
    agent.vm.provision :shell, :inline => 'iex "puppet apply -v C:/vagrant/tests/sensu-agent-windows-chocolatey.pp"'
    agent.vm.provision :shell, :inline => 'iex "facter --custom-dir=C:/vagrant/lib/facter sensu_version"'
  end

  config.vm.define "debian9-agent", autostart: false do |agent|
    agent.vm.box = "debian/stretch64"
    agent.vm.hostname = 'debian9-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.20"
    agent.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "debian8-agent", autostart: false do |agent|
    agent.vm.box = "debian/jessie64"
    agent.vm.hostname = 'debian8-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.17"
    agent.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  config.vm.define "debian7-agent", autostart: false do |agent|
    agent.vm.box = "debian/wheezy64"
    agent.vm.hostname = 'debian7-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.18"
    agent.vm.provision :shell, :path => "tests/provision_basic_debian.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
  end

  # The rsync used to populate /vagrant will fail if the repo has the spec
  # fixtures created. To avoid, run `rake spec_clean` before `vagrant up`.
  config.vm.define "macos-agent", autostart: false do |agent|
    agent.vm.box = "jhcook/macos-sierra"
    agent.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
    agent.vm.hostname = 'macos-agent.example.com'
    agent.vm.network  :private_network, ip: "192.168.52.19"
    agent.vm.synced_folder ".", "/vagrant", type: "rsync", group: "wheel"
    agent.vm.provision :shell, :path => "tests/provision_macos.sh"
    agent.vm.provision :shell, :inline => "puppet apply /vagrant/tests/sensu-agent.pp"
    agent.vm.provision :shell, :inline => "facter --custom-dir=/vagrant/lib/facter sensu_version"
    agent.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--usb", "on"]
      vb.customize ["modifyvm", :id, "--usbehci", "off"]
    end
  end
end
