require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    if host.is_pe?
      install_pe
    else
      install_puppet
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

UNSUPPORTED_PLATFORMS = ['windows']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'sensu')
    hosts.each do |host|
      if fact('osfamily') == 'Debian'
        # RubyGems missing on some Vagrant boxes
        # Otherwise you'lll get a load of 'Provider gem is not functional on this host'
        shell('apt-get install rubygems -y')
      end
      if fact('osfamily') == 'RedHat'
        # RedHat needs EPEL for RabbitMQ and Redis
        shell('wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && sudo rpm -Uvh epel-release-6*.rpm')
      end
      shell('/bin/touch /etc/puppet/hiera.yaml')
      shell('puppet module install puppetlabs-stdlib --version 3.2.0', { :acceptable_exit_codes => [0,1] })
      shell('puppet module install maestrodev/wget --version 1.4.5', { :acceptable_exit_codes => [0,1] })
      shell('puppet module install puppetlabs-rabbitmq --version 4.1.0', { :acceptable_exit_codes => [0,1] })
      shell('puppet module install fsalum-redis --version 1.0.0', { :acceptable_exit_codes => [0,1] })
      shell('puppet module install puppetlabs/apt --version 1.6.0', { :acceptable_exit_codes => [0,1] })
    end
  end
end
