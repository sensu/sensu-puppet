require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['RS_provision'] == 'no'
  hosts.each do |host|
    if host.is_pe?
      install_pe
    else
      install_puppet
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'sensu')

      if fact('osfamily') == 'Debian' and fact('operatingsystemmajrelease') == '12.04'
        # RubyGems missing on some Ubuntu 12 boxes
        # Otherwise you'lll get a load of 'Provider gem is not functional on this host'
        shell('apt-get install rubygems -y')
      end
      if fact('osfamily') == 'RedHat'
        # CentOS has epel-release package in Extras, enabled by default
        shell('yum -y install epel-release')
        shell('yum -y install erlang')
      end
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'maestrodev-wget'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppet-rabbitmq'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'fsalum-redis'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-powershell'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
