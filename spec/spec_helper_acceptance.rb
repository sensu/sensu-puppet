require 'rspec'
RSpec.configure do |c|
  c.add_setting :sensu_mode, default: 'base'
  c.add_setting :sensu_enterprise_file, default: nil
  c.add_setting :sensu_test_enterprise, default: false
  c.add_setting :add_ci_repo, default: false
  c.add_setting :sensu_manage_repo, default: true
  c.add_setting :sensu_use_agent, default: false
  c.add_setting :examples_dir, default: nil
  c.add_setting :sensu_examples, default: []
  c.add_setting :skip_apply, default: false
end

if ENV['RUN_ACCEPTANCE'] != '1'
  require 'rspec'
  RSpec.configure do |c|
    c.before(:context) do
      skip('Acceptance tests disabled (set RUN_ACCEPTANCE=1 to enable)')
    end
  end
  return
end
ENV['BEAKER_set'] ||= 'rocky-8'
ENV['BEAKER_HYPERVISOR'] ||= 'docker'
ENV['PUPPET_INSTALL_TYPE'] ||= 'agent'
ENV['PUPPET_COLLECTION'] ||= 'puppet7'
require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/module_install_helper'
require 'beaker/puppet_install_helper'
require 'beaker/command'
# require 'simp/beaker_helpers'

# include Simp::BeakerHelpers
# Install Puppet using standard helper for all platforms
hosts.each do |host|
  if host['platform'] =~ /el-8/
    # Install sensu-go-cli for sensuctl command
    host.exec(Beaker::Command.new('dnf install -y sensu-go-cli || true'))
    
    # Verify sensuctl is installed
    host.exec(Beaker::Command.new('sensuctl version || true'))
  end
end

# Use standard Puppet installation helper with retry logic for dpkg locks
# Install Puppet on hosts sequentially to avoid dpkg lock conflicts
hosts.each do |host|
  max_retries = 3
  retry_count = 0
  begin
    run_puppet_install_helper_on(host)
  rescue Beaker::Host::CommandFailure => e
    if e.message.include?('dpkg frontend lock') && retry_count < max_retries
      retry_count += 1
      logger.warn("dpkg lock detected on #{host}, waiting 5 seconds before retry #{retry_count}/#{max_retries}")
      sleep 5
      retry
    else
      raise
    end
  end
end

# Verify Puppet is installed on all hosts
hosts.each do |host|
  host.exec(Beaker::Command.new('puppet --version'))
end

# Install the module on all hosts
install_module_on(hosts)
# pluginsync_on(hosts)  # Replaced with standard beaker method
collection = ENV['BEAKER_PUPPET_COLLECTION'] || 'puppet7'
project_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

RSpec.configure do |c|
  c.sensu_mode = ENV['BEAKER_sensu_mode'] unless ENV['BEAKER_sensu_mode'].nil?
  c.sensu_use_agent = (ENV['BEAKER_sensu_use_agent'] == 'yes' || ENV['BEAKER_sensu_use_agent'] == 'true')
  if ENV['SENSU_ENTERPRISE_FILE']
    enterprise_file = File.absolute_path(ENV['SENSU_ENTERPRISE_FILE'])
  else
    enterprise_file = File.join(project_dir, 'tests/sensu_license.json')
  end
  if File.exist?(enterprise_file)
    scp_to(hosts_as('sensu-backend'), enterprise_file, '/root/sensu_license.json')
    c.sensu_test_enterprise = true
  else
    c.sensu_test_enterprise = false
  end

  ci_build = File.join(project_dir, 'tests/ci_build.sh')
  secrets = File.join(project_dir, 'tests/secrets')
  if File.exist?(secrets) && (ENV['BEAKER_sensu_ci_build'] == 'yes' || ENV['BEAKER_sensu_ci_build'] == 'true')
    c.sensu_manage_repo = false
    c.add_ci_repo = true
  end

  c.examples_dir = File.join(project_dir, 'examples')
  c.sensu_examples = Dir["#{c.examples_dir}/*.pp"]

  if RSpec.configuration.sensu_use_agent
    puppetserver = hosts_as('puppetserver')[0]
    setup_nodes = puppetserver
  else
    setup_nodes = hosts
  end

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install soft module dependencies
    on setup_nodes, puppet('module', 'install', 'puppetlabs-apt', '--version', '">= 5.0.1 < 9.0.0"'), { :acceptable_exit_codes => [0,1] }
    on setup_nodes, puppet('module', 'install', 'puppetlabs-yumrepo_core', '--version', '">= 1.0.1 < 2.0.0"'), { :acceptable_exit_codes => [0,1] }
    # Dependencies only needed to test some examples
    if RSpec.configuration.sensu_mode == 'examples'
      on setup_nodes, puppet('module', 'install', 'puppet-logrotate', '--version', '5.0.0')
      on setup_nodes, puppet('module', 'install', 'saz-rsyslog', '--version', '5.0.0')
      # rsyslog template relies on rsyslog_version fact so pre-install rsyslog
      # to keep things idempotent within minimal docker containers
      on hosts, puppet('resource', 'package', 'rsyslog', 'ensure=present')
    end
    install_module_dependencies
    ssldir = File.join(project_dir, 'tests/ssl')
    scp_to(hosts, ssldir, '/etc/puppetlabs/puppet/')
    hosts.each do |host|
      on host, "puppet config set --section main certname #{host.name}"
    end

    if c.add_ci_repo
      scp_to(hosts, ci_build, '/tmp/ci_build.sh')
      scp_to(hosts, secrets, '/tmp/secrets')
      on hosts, '/tmp/ci_build.sh'
    end
    hiera_yaml = <<-EOS
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: "Common"
    path: "common.yaml"
EOS
    common_yaml = <<-EOS
---
sensu::manage_repo: #{RSpec.configuration.sensu_manage_repo}
sensu::plugins::manage_repo: true
sensu::api_host: sensu-backend
sensu::ssl_ca_source: '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem'
sensu::backend::ssl_cert_source: '/etc/puppetlabs/puppet/ssl/ca/signed/sensu-backend.pem'
sensu::backend::ssl_key_source: '/etc/puppetlabs/puppet/ssl/private_keys/sensu-backend_key.pem'
postgresql::globals::encoding: UTF8
postgresql::globals::locale: C
postgresql::server::service_status: 'systemctl status postgresql-11 1>/dev/null 2>&1'
postgresql::server::service_reload: 'systemctl reload postgresql-11 1>/dev/null 2>&1'
EOS
    create_remote_file(setup_nodes, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
    on setup_nodes, 'mkdir -p -m 0755 /etc/puppetlabs/puppet/data'
    create_remote_file(setup_nodes, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)

    if RSpec.configuration.sensu_use_agent
      puppetserver = hosts_as('puppetserver')[0]
      if RSpec.configuration.sensu_mode == 'cluster'
        server = 'sensu-backend1'
      else
        server = 'sensu-backend'
      end
      on hosts, puppet("config set --section main server #{server}")
      on puppetserver, puppet("resource package puppetserver ensure=installed")
      on puppetserver, puppet("resource service puppetserver ensure=running")
      on puppetserver, 'chmod 0644 /etc/puppetlabs/puppet/hiera.yaml'
      on puppetserver, 'chmod 0644 /etc/puppetlabs/puppet/data/common.yaml'
      create_remote_file(puppetserver, '/etc/puppetlabs/code/environments/production/manifests/site.pp', '')
      on puppetserver, "chmod 0644 /etc/puppetlabs/code/environments/production/manifests/site.pp"
    end

    # Setup Puppet Bolt
    if RSpec.configuration.sensu_mode == 'bolt'
      on setup_nodes, puppet("resource package puppet-bolt ensure=installed")
      bolt_inventory_cfg = <<-EOS
config:
  transport: ssh
  ssh:
    host-key-check: false
    user: root
    password: root
EOS
      bolt_project_cfg = <<-EOS
modulepath:
- "/etc/puppetlabs/code/modules"
- "/etc/puppetlabs/code/environments/production/modules"
EOS
      on setup_nodes, 'mkdir -p -m 0755 /root/.puppetlabs/bolt'
      create_remote_file(setup_nodes, '/root/.puppetlabs/bolt/inventory.yaml', bolt_inventory_cfg)
      create_remote_file(setup_nodes, '/root/.puppetlabs/bolt/bolt-project.yaml', bolt_project_cfg)
    end
  end
end
