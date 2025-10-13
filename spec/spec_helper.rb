require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |config|
  config.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'

# Fix stdlib module loading issue for rspec-puppet tests
RSpec.configure do |config|
  config.before(:each) do
    # Set the module path to include our fixtures
    fixture_modules = File.join(File.dirname(__FILE__), 'fixtures', 'modules')
    if Dir.exist?(fixture_modules)
      # Set Puppet settings for module resolution
      Puppet.settings[:modulepath] = fixture_modules
      
      # Reset the current environment to ensure fresh module loading
      Puppet.push_context(environment: nil)
      env = Puppet.lookup(:current_environment)
      if env
        env.instance_variable_set(:@modulepath, [fixture_modules])
      end
    end
  end
  
  config.after(:each) do
    Puppet.pop_context if Puppet.respond_to?(:pop_context)
  end
end

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
  # Exclude acceptance specs by default; enable with RUN_ACCEPTANCE=1
  if ENV['RUN_ACCEPTANCE'] != '1'
    config.exclude_pattern = [
      'spec/acceptance/**/*',
      'spec/spec_helper_acceptance.rb',
      'spec/spec_helper_acceptance_windows.rb'
    ]
  end
  # Also constrain default pattern to non-acceptance suites to avoid eager load of acceptance helpers
  if ENV['RUN_ACCEPTANCE'] != '1'
    config.pattern = '{spec,./spec}/{unit,classes,defines,functions,hosts,tasks,type_aliases,shared_examples}/**/*_spec.rb'
  end
  
  config.before(:suite) do
    # This hook runs once before all tests to ensure a clean slate.
    # It removes the entire modules directory from the fixtures to prevent
    # stale symlinks from causing "File exists" errors.
    spec_dir = File.dirname(__FILE__)
    modules_dir = File.join(spec_dir, 'fixtures', 'modules')

    # Aggressively remove and recreate the directory.
    FileUtils.rm_rf(modules_dir) if File.directory?(modules_dir)
    FileUtils.mkdir_p(modules_dir)
  end

  config.mock_with :rspec
  config.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  
  # Set up module path for rspec-puppet
  config.manifest_dir = File.join(File.dirname(__FILE__), 'fixtures', 'manifests')
  config.module_path = File.join(File.dirname(__FILE__), 'fixtures', 'modules')
  
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter.clear

    # Ensure Puppet config initialization doesn't try and create directories that may not be writable
    Puppet[:logdir] = '/tmp'
    Puppet[:confdir] = '/tmp'
    Puppet[:vardir] = '/tmp'
    Puppet[:codedir] = '/tmp'
    
    # Ensure modulepath includes fixtures for stdlib type resolution
    fixtures_modules_path = File.join(__dir__, 'fixtures', 'modules')
    if Dir.exist?(fixtures_modules_path)
      Puppet[:modulepath] = fixtures_modules_path
      # Also ensure the current environment uses the same modulepath for catalog compilation
      env = Puppet.lookup(:current_environment)
      if env && env.respond_to?(:modulepath=)
        env.modulepath = [fixtures_modules_path]
      end
    end
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
    :service_provider          => 'systemd',
    :fqdn                      => 'testfqdn.example.com',
    :puppet_hostcert           => '/dne/cert.pem',
    :puppet_hostprivkey        => '/dne/key.pem',
    :choco_install_path        => 'C:\ProgramData\chocolatey',
    :chocolateyversion         => '1.0.0',
  }
  config.backtrace_exclusion_patterns = [
    %r{/\.bundle/},
    %r{/\.rbenv/},
    %r{/.rvm/},
  ]
  config.default_facter_version = '3.11.9'
end

add_custom_fact :puppet_localcacert, ->(os, facts) {
  case facts[:osfamily]
  when 'windows'
    "C:\\ProgramData\\ca.crt"
  else
    '/dne/ca.pem'
  end
}

# Gets an array of types that have sensuctl provider
# This logic is similar to that used by sensuctl_config type
# Used in sensuctl_config tests
def sensuctl_types
  types = []
  Dir[File.join(File.dirname(__FILE__), '..', 'lib/puppet/provider') + '/sensu_*/sensuctl.rb'].each do |f|
    type = File.basename(File.dirname(f))
    types << type.to_sym
  end
  types
end

def platforms
  {
    'Debian' => {
      :package_require => ['Class[Sensu::Repo]', 'Class[Apt::Update]'],
      package_provider: nil,
      :plugins_package_require => ['Class[Sensu::Repo::Community]', 'Class[Apt::Update]'],
      :plugins_dependencies => ['make','gcc','g++','libssl-dev'],
      agent_package_name: 'sensu-go-agent',
      :agent_config_path => '/etc/sensu/agent.yml',
      agent_config_mode: '0640',
      etc_dir: '/etc/sensu',
      etc_parent_dir: nil,
      ssl_dir: '/etc/sensu/ssl',
      ca_path: '/etc/sensu/ssl/ca.crt',
      user: 'sensu',
      group: 'sensu',
      ssl_dir_mode: '0700',
      etc_dir_mode: '0755',
      ca_mode: '0644',
      agent_service_name: 'sensu-agent',
      log_file: nil,
      agent_service_env_vars_file: '/etc/default/sensu-agent',
      backend_service_env_vars_file: '/etc/default/sensu-backend',
    },
    'RedHat' => {
      :package_require => ['Class[Sensu::Repo]'],
      package_provider: nil,
      :plugins_package_require => ['Class[Sensu::Repo::Community]'],
      :plugins_dependencies => ['make','gcc','gcc-c++','openssl-devel'],
      agent_package_name: 'sensu-go-agent',
      :agent_config_path => '/etc/sensu/agent.yml',
      agent_config_mode: '0640',
      ssl_dir: '/etc/sensu/ssl',
      etc_dir: '/etc/sensu',
      etc_parent_dir: nil,
      ca_path: '/etc/sensu/ssl/ca.crt',
      user: 'sensu',
      group: 'sensu',
      ssl_dir_mode: '0700',
      etc_dir_mode: '0755',
      ca_mode: '0644',
      agent_service_name: 'sensu-agent',
      log_file: nil,
      agent_service_env_vars_file: '/etc/sysconfig/sensu-agent',
      backend_service_env_vars_file: '/etc/sysconfig/sensu-backend',
    },
    'windows' => {
      agent_package_name: 'sensu-agent',
      package_provider: 'chocolatey',
      :agent_config_path => 'C:\ProgramData\Sensu\config\agent.yml',
      agent_config_mode: nil,
      etc_dir: 'C:\\ProgramData\\Sensu\\config',
      etc_parent_dir: 'C:\\ProgramData\\Sensu',
      ssl_dir: 'C:\\ProgramData\\Sensu\\config\\ssl',
      ca_path: 'C:\\ProgramData\\Sensu\\config\\ssl\\ca.crt',
      user: nil,
      group: nil,
      ssl_dir_mode: nil,
      etc_dir_mode: nil,
      ca_mode: nil,
      plugins_dependencies: [],
      agent_service_name: 'SensuAgent',
      log_file: 'C:\ProgramData\sensu\log\sensu-agent.log',
      agent_service_env_vars_file: nil,
      backend_service_env_vars_file: nil,
    }
  }
end