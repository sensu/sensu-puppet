require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/module_install_helper'
require 'beaker/puppet_install_helper'
require 'simp/beaker_helpers'

include Simp::BeakerHelpers
run_puppet_install_helper
install_module
pluginsync_on(hosts)
collection = ENV['BEAKER_PUPPET_COLLECTION'] || 'puppet6'
project_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

# Wait helpers to accommodate slower startup on newer Sensu versions
def wait_for_command(host, command, max_retries = 30, sleep_seconds = 5)
  retries = 0
  until retries >= max_retries
    result = on(host, command, acceptable_exit_codes: [0,1,2,3,4,5,6], silent: true) rescue nil
    return true if result && result.exit_code == 0
    sleep sleep_seconds
    retries += 1
  end
  false
end

def wait_for_backend(host)
  wait_for_command(host, 'sensuctl cluster health')
end

RSpec.configure do |c|
  c.add_setting :sensu_mode, default: 'base'
  c.add_setting :sensu_enterprise_file, default: nil
  c.add_setting :sensu_test_enterprise, default: false
  c.add_setting :add_ci_repo, default: false
  c.add_setting :sensu_manage_repo, default: true
  c.add_setting :sensu_use_agent, default: false
  c.add_setting :examples_dir, default: nil
  c.add_setting :sensu_examples, default: []
  # Necessary to be present even though only used by Windows tests
  c.add_setting :skip_apply, default: false
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
    # Avoid copying static, possibly expired test CA by default.
    # Use SENSU_TEST_SSL=true to force using repo-provided SSL fixtures.
    if ENV['SENSU_TEST_SSL'] == 'true'
      scp_to(hosts, ssldir, '/etc/puppetlabs/puppet/')
    end
    hosts.each do |host|
      on host, "puppet config set --section main certname #{host.name}"
    end

    if c.add_ci_repo
      scp_to(hosts, ci_build, '/tmp/ci_build.sh')
      scp_to(hosts, secrets, '/tmp/secrets')
      on hosts, '/tmp/ci_build.sh'
    end
    # Generate fresh SSL materials on test hosts and point module to them
    on setup_nodes, 'mkdir -p -m 0755 /etc/sensu/ssl'
    on setup_nodes, 'openssl genrsa -out /etc/sensu/ssl/ca.key 2048 2>/dev/null'
    on setup_nodes, "openssl req -x509 -new -nodes -key /etc/sensu/ssl/ca.key -subj '/C=US/ST=CI/L=CI/O=CI/OU=CI/CN=SensuTestCA' -days 3650 -out /etc/sensu/ssl/ca.crt 2>/dev/null"
    on setup_nodes, 'openssl genrsa -out /etc/sensu/ssl/key.pem 2048 2>/dev/null'
    on setup_nodes, "openssl req -new -key /etc/sensu/ssl/key.pem -subj '/C=US/ST=CI/L=CI/O=CI/OU=CI/CN=localhost' -out /etc/sensu/ssl/server.csr 2>/dev/null"
    # Create SSL config file with multiple SANs - sensu-backend must be first
    on setup_nodes, 'echo -e "basicConstraints=CA:FALSE\nkeyUsage=nonRepudiation,digitalSignature,keyEncipherment\nsubjectAltName=DNS:sensu-backend,DNS:localhost,IP:127.0.0.1" > /etc/sensu/ssl/san.conf'
    # Generate certificate with SANs
    on setup_nodes, 'openssl x509 -req -in /etc/sensu/ssl/server.csr -CA /etc/sensu/ssl/ca.crt -CAkey /etc/sensu/ssl/ca.key -CAcreateserial -out /etc/sensu/ssl/cert.pem -days 3650 -sha256 -extfile /etc/sensu/ssl/san.conf -extensions v3_req'
    # Add hostname to hosts file to ensure proper resolution
    on setup_nodes, 'echo "127.0.0.1 sensu-backend" >> /etc/hosts'
    on setup_nodes, 'chown -R sensu:sensu /etc/sensu/ssl 2>/dev/null || chown -R 1000:1000 /etc/sensu/ssl 2>/dev/null || true'
    on setup_nodes, 'chmod 600 /etc/sensu/ssl/*.key /etc/sensu/ssl/*.pem 2>/dev/null || true'
    on setup_nodes, 'chmod 644 /etc/sensu/ssl/*.crt 2>/dev/null || true'
    # Verify SSL files were created
    on setup_nodes, 'ls -la /etc/sensu/ssl/'
    on setup_nodes, 'openssl x509 -in /etc/sensu/ssl/ca.crt -text -noout | head -5'
    # Verify the certificate has proper SANs
    on setup_nodes, 'openssl x509 -in /etc/sensu/ssl/cert.pem -text -noout | grep -A10 "Subject Alternative Name" || echo "SAN verification failed"'


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
sensu::ssl_ca_source: 'file:/etc/sensu/ssl/ca.crt'
sensu::backend::ssl_cert_source: 'file:/etc/sensu/ssl/cert.pem'
sensu::backend::ssl_key_source: 'file:/etc/sensu/ssl/key.pem'
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
