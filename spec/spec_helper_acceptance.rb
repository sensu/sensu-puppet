require 'beaker-rspec'
require 'beaker/module_install_helper'

install_puppet_agent_on(hosts, :puppet_collection => 'puppet5', :puppet_agent_version => ENV['PUPPET_INSTALL_VERSION'], :run_in_parallel => true)
proj = File.join(File.dirname(__FILE__), '..')
if fact('osfamily') == 'windows'
  modulepath = 'C:/ProgramData/PuppetLabs/code/modules'
else
  modulepath = '/etc/puppetlabs/code/modules'
end
copy_module_to(hosts, :source => proj, :module_name => 'sensu', :target_module_path => modulepath)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module dependencies
    on hosts, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1], :run_in_parallel => true }
    on hosts, puppet('module', 'install', 'puppetlabs-apt'), { :acceptable_exit_codes => [0,1], :run_in_parallel => true }
  end
end
