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
    :puppet_hostcert           => '/dne/cert.pem',
    :puppet_hostprivkey        => '/dne/key.pem',
  }
  config.backtrace_exclusion_patterns = [
    %r{/\.bundle/},
    %r{/\.rbenv/},
    %r{/.rvm/},
  ]
end

add_custom_fact :puppet_localcacert, ->(os, facts) {
  case facts[:osfamily]
  when 'windows'
    "C:\\ProgramData\\ca.crt"
  else
    '/dne/ca.pem'
  end
}

def platforms
  {
    'Debian' => {
      :package_require => ['Class[Sensu::Repo]', 'Class[Apt::Update]'],
      :plugins_package_require => ['Class[Sensu::Repo::Community]', 'Class[Apt::Update]'],
      :plugins_dependencies => ['make','gcc','g++','libssl-dev'],
      agent_package_name: 'sensu-go-agent',
      :agent_config_path => '/etc/sensu/agent.yml',
      agent_config_mode: '0640',
      etc_dir: '/etc/sensu',
      ssl_dir: '/etc/sensu/ssl',
      ca_path: '/etc/sensu/ssl/ca.crt',
      ca_path_yaml: '"/etc/sensu/ssl/ca.crt"',
      user: 'sensu',
      group: 'sensu',
      ssl_dir_mode: '0700',
      ca_mode: '0644',
      agent_service_name: 'sensu-agent',
      log_file: nil,
    },
    'RedHat' => {
      :package_require => ['Class[Sensu::Repo]'],
      :plugins_package_require => ['Class[Sensu::Repo::Community]'],
      :plugins_dependencies => ['make','gcc','gcc-c++','openssl-devel'],
      agent_package_name: 'sensu-go-agent',
      :agent_config_path => '/etc/sensu/agent.yml',
      agent_config_mode: '0640',
      ssl_dir: '/etc/sensu/ssl',
      etc_dir: '/etc/sensu',
      ca_path: '/etc/sensu/ssl/ca.crt',
      ca_path_yaml: '"/etc/sensu/ssl/ca.crt"',
      user: 'sensu',
      group: 'sensu',
      ssl_dir_mode: '0700',
      ca_mode: '0644',
      agent_service_name: 'sensu-agent',
      log_file: nil,
    },
    'windows' => {
      agent_package_name: 'Sensu Agent',
      :agent_config_path => 'C:\ProgramData\Sensu\config\agent.yml',
      agent_config_mode: nil,
      etc_dir: 'C:\\ProgramData\\Sensu\\config',
      ssl_dir: 'C:\\ProgramData\\Sensu\\config\\ssl',
      ca_path: 'C:\\ProgramData\\Sensu\\config\\ssl\\ca.crt',
      ca_path_yaml: 'C:\\ProgramData\\Sensu\\config\\ssl\\ca.crt',
      user: nil,
      group: nil,
      ssl_dir_mode: nil,
      ca_mode: nil,
      plugins_dependencies: [],
      agent_service_name: 'SensuAgent',
      log_file: 'C:\ProgramData\sensu\log\sensu-agent.log',
    }
  }
end
