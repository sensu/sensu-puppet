require 'beaker-rspec'
require 'beaker-puppet'
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
  c.add_setting :sensu_full, default: false
  c.add_setting :sensu_cluster, default: false
  c.sensu_full = (ENV['BEAKER_sensu_full'] == 'yes' || ENV['BEAKER_sensu_full'] == 'true')
  c.sensu_cluster = (ENV['BEAKER_sensu_cluster'] == 'yes' || ENV['BEAKER_sensu_cluster'] == 'true')

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module dependencies
    on hosts, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1], :run_in_parallel => true }
    on hosts, puppet('module', 'install', 'puppetlabs-apt', '--version', '">= 4.0.0 < 5.0.0"'), { :acceptable_exit_codes => [0,1], :run_in_parallel => true }
  end
end
