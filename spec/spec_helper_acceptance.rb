require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/module_install_helper'
require 'beaker/puppet_install_helper'

run_puppet_install_helper
install_module_dependencies
install_module

RSpec.configure do |c|
  c.add_setting :sensu_full, default: false
  c.add_setting :sensu_cluster, default: false
  c.sensu_full = (ENV['BEAKER_sensu_full'] == 'yes' || ENV['BEAKER_sensu_full'] == 'true')
  c.sensu_cluster = (ENV['BEAKER_sensu_cluster'] == 'yes' || ENV['BEAKER_sensu_cluster'] == 'true')

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install soft module dependencies
    on hosts, puppet('module', 'install', 'puppetlabs-apt', '--version', '">= 5.0.1 < 6.0.0"'), { :acceptable_exit_codes => [0,1] }
  end
end
