require 'beaker-rspec'
# Helper does not yet support Puppet 5
#require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

# This allows local windows testing with appveyor
require 'beaker/testmode_switcher/dsl'

# Helper does not yet support Puppet 5
#install_puppetlabs_release_repo_on(hosts, 'puppet5')
install_puppet_agent_on(hosts, :puppet_collection => 'puppet5', :puppet_agent_version => ENV['PUPPET_INSTALL_VERSION'])
#run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

UNSUPPORTED_PLATFORMS = ['Suse','AIX','Solaris']

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      if fact('osfamily') == 'RedHat'
        # CentOS has epel-release package in Extras, enabled by default
        shell('yum -y install epel-release')
      end
      on host, puppet('module', 'install', 'puppet-rabbitmq'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'fsalum-redis'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-powershell'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
