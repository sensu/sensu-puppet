require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/module_install_helper'
require 'beaker/puppet_install_helper'
require 'simp/beaker_helpers'
require 'json'

# On Apple Silicon (arm64), Puppet's EL aarch64 yum CloudFront distribution
# returns 403 specifically for libdnf user-agent requests. Override dnf's
# user_agent before puppet-agent is installed so the repo responds with 200.
if RbConfig::CONFIG['host_cpu'] == 'arm64'
  on hosts, "echo 'user_agent=curl/8.0' >> /etc/dnf/dnf.conf", acceptable_exit_codes: [0, 1]
end

include Simp::BeakerHelpers
run_puppet_install_helper_on(hosts)
install_module
pluginsync_on(hosts)
project_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

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
    # Install metadata.json dependencies first so stdlib 9.x+ is present
    # before soft dependencies (puppetlabs-apt etc.) pull in an older stdlib.
    metadata = JSON.parse(File.read(File.join(project_dir, 'metadata.json')))
    metadata.fetch('dependencies', []).each do |dep|
      mod  = dep['name'].sub('/', '-')
      ver  = dep['version_requirement']
      args = ver ? [mod, '--version', "\"#{ver}\""] : [mod]
      on setup_nodes, puppet('module', 'install', *args), acceptable_exit_codes: [0, 1]
    end
    # Install soft module dependencies
    # puppetlabs-apt is omitted: puppetlabs-postgresql (a metadata dep) already
    # requires apt >= 9.2.0 and installs it, making a separate apt install conflict.
    on setup_nodes, puppet('module', 'install', 'puppetlabs-yumrepo_core', '--version', '">= 1.0.1 < 2.0.0"'), { :acceptable_exit_codes => [0,1] }
    # puppetlabs-concat is a transitive dep of puppetlabs-postgresql; install it
    # explicitly because puppet module install can silently skip transitive deps
    # when the parent module is already cached in a preserved Docker image.
    on setup_nodes, puppet('module', 'install', 'puppetlabs-concat', '--version', '">= 4.1.0 < 11.0.0"'), { :acceptable_exit_codes => [0,1] }
    # puppetlabs-inifile is a transitive dep of puppet-systemd (used by journald.pp)
    on setup_nodes, puppet('module', 'install', 'puppetlabs-inifile', '--version', '">= 1.6.0 < 7.0.0"'), { :acceptable_exit_codes => [0,1] }
    # full mode uses PostgreSQL via the PGDG yum repo. Rocky 9's dnf won't
    # auto-import new repo GPG keys non-interactively, so pre-bootstrap the
    # PGDG repo RPM which imports keys via rpm --import before puppet runs.
    if RSpec.configuration.sensu_mode == 'full' || RSpec.configuration.sensu_mode == 'examples'
      # Bootstrap the PGDG yum repo RPM on EL systems (imports GPG keys via
      # rpm --import) so dnf can install PGDG packages non-interactively.
      # Skipped silently on Debian/Ubuntu where dnf is not installed.
      on hosts, "if command -v dnf >/dev/null 2>&1; then arch=$(uname -m) && dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-${arch}/pgdg-redhat-repo-latest.noarch.rpm; fi", acceptable_exit_codes: [0, 1]
    end
    # Dependencies only needed to test some examples
    if RSpec.configuration.sensu_mode == 'examples'
      on setup_nodes, puppet('module', 'install', 'puppet-logrotate', '--version', '">= 8.0.0 < 10.0.0"', '--ignore-dependencies')
      on setup_nodes, puppet('module', 'install', 'puppet-rsyslog', '--version', '">= 8.0.0 < 10.0.0"', '--ignore-dependencies')
    end
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
    backend_platform = hosts_as('sensu-backend').first['platform'].to_s
    pg_service = backend_platform.match?(/ubuntu|debian/) ? 'postgresql@16-main' : 'postgresql-16'
    if backend_platform.match?(/ubuntu|debian/)
      on hosts_as('sensu-backend'), "ln -sf /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt", acceptable_exit_codes: [0, 1]
    end
    common_yaml = <<-EOS
---
sensu::manage_repo: #{RSpec.configuration.sensu_manage_repo}
sensu::plugins::manage_repo: true
sensu::api_host: sensu-backend
postgresql::globals::encoding: UTF8
postgresql::globals::locale: C
postgresql::server::service_status: 'systemctl status #{pg_service} 1>/dev/null 2>&1'
postgresql::server::service_reload: 'systemctl reload #{pg_service} 1>/dev/null 2>&1'
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
      # Wait for puppetserver JVM to finish startup and bind port 8140 (can take 30-90s).
      retry_on(puppetserver, 'wget -q --no-check-certificate -O - https://localhost:8140/status/v1/simple 2>/dev/null | grep -q running', max_retries: 60, retry_interval: 5)
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
