require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |config|
  config.mock_with :rspec
end
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

dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/shared_examples/**/*.rb"].sort.each {|f| require f}

module_spec_dir = File.dirname(__FILE__)
custom_facts = File.join(module_spec_dir, 'fixtures', 'facts')
ENV['FACTERDB_SEARCH_PATHS'] = custom_facts

RSpec.configure do |config|
  config.mock_with :rspec
  config.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter.clear
  end
  config.default_facts = {
    :environment               => 'rp_env',
    :ipaddress                 => '127.0.0.1',
    :kernel                    => 'Linux',
    :osfamily                  => 'RedHat',
    :os                        => {
      :family => 'RedHat',
    },
    :operatingsystem           => 'RedHat',
    :operatingsystemmajrelease => '7',
    :fqdn                      => 'testfqdn.example.com',
    :puppet_localcacert        => '/dne/ca.pem',
    :puppet_hostcert           => '/dne/cert.pem',
    :puppet_hostprivkey        => '/dne/key.pem',
  }
  config.backtrace_exclusion_patterns = [
    %r{/\.bundle/},
    %r{/\.rbenv/},
    %r{/.rvm/},
  ]
end

def platforms
  {
    'Debian' => {
      :package_require => ['Class[Sensu::Repo]', 'Class[Apt::Update]'],
      :plugins_package_require => ['Class[Sensu::Repo::Community]', 'Class[Apt::Update]'],
      :plugins_dependencies => ['make','gcc','g++','libssl-dev'],
    },
    'RedHat' => {
      :package_require => ['Class[Sensu::Repo]'],
      :plugins_package_require => ['Class[Sensu::Repo::Community]'],
      :plugins_dependencies => ['make','gcc','gcc-c++','openssl-devel'],
    },
  }
end
