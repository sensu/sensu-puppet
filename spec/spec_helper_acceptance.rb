require 'serverspec'
if ! Gem.win_platform?
  require 'beaker-rspec'
  require 'beaker-puppet'
  require 'beaker/puppet_install_helper'
  require 'beaker/module_install_helper'

  run_puppet_install_helper
  install_module_dependencies
  install_module
  collection = ENV['BEAKER_PUPPET_COLLECTION'] || 'puppet5'
end

if Gem.win_platform?
  set :backend, :cmd
end

if Gem.win_platform?
  # Normally provided by beaker but can't load beaker for Windows run tests
  # that run locally in appveyor.
  def fact(v)
    if v == 'osfamily'
      'windows'
    end
  end
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    if ! Gem.win_platform?
      # Install module and dependencies
      hosts.each do |host|
        if fact('osfamily') == 'RedHat' && fact('operatingsystem') != 'Amazon'
          # CentOS has epel-release package in Extras, enabled by default
          shell('yum -y install epel-release')
        end
        on host, puppet('module', 'install', 'puppet-rabbitmq'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module', 'install', 'fsalum-redis'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module', 'install', 'puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module', 'install', 'puppetlabs-dsc'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module', 'install', 'puppetlabs-acl'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module', 'install', 'puppetlabs-powershell'), { :acceptable_exit_codes => [0,1] }
        if collection == 'puppet6'
          on hosts, puppet('module', 'install', 'puppetlabs-yumrepo_core', '--version', '">= 1.0.1 < 2.0.0"'), { :acceptable_exit_codes => [0,1] }
        end
      end
    end
  end
end
