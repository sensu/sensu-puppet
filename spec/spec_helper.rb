require 'puppetlabs_spec_helper/module_spec_helper'

case ENV['COVERAGE']
when 'SimpleCov'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/fixtures/'
    add_filter '/spec/'
  end
when 'rspec-puppet'
  at_exit { RSpec::Puppet::Coverage.report! }
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter.clear
    Facter.clear_messages
  end
  config.default_facts = {
    :environment => 'rp_env',
    :ipaddress   => '127.0.0.1',
    :kernel      => 'Linux',
    :osfamily    => 'RedHat',
    :operatingsystem => 'RedHat',
    :fqdn        => 'testfqdn.example.com',
  }
  config.backtrace_exclusion_patterns = [
    %r{/\.bundle/},
    %r{/\.rbenv/},
    %r{/.rvm/},
  ]
end
