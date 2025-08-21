require 'spec_helper_acceptance'

describe 'sensu::backend class', if: ['base'].include?(RSpec.configuration.sensu_mode) do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password       => 'supersecret',
      }
      class { 'sensu::backend':
        include_default_resources => false,
      }
      EOS

      # Debug: Check SSL files before applying manifest
      on node, 'ls -la /etc/sensu/ssl/ || echo "SSL dir not found"'
      on node, 'cat /etc/sensu/ssl/ca.crt | head -3 || echo "CA file not readable"'
      on node, 'cat /etc/sensu/ssl/cert.pem | head -3 || echo "Cert file not readable"'
      on node, 'cat /etc/sensu/ssl/key.pem | head -3 || echo "Key file not readable"'

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        # Debug: Check what happened after manifest
        on node, 'systemctl status sensu-backend || echo "Service status check failed"'
        on node, 'journalctl -u sensu-backend --no-pager -n 20 || echo "Journal check failed"'
        on node, 'ls -la /etc/sensu/ || echo "Sensu dir check failed"'
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
    it 'waits for backend to be healthy' do
      expect(wait_for_backend(node)).to eq(true)
    end
    describe package('sensu-go-agent'), :node => node do
      it { should_not be_installed }
    end
  end

  context 'default resources' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password       => 'supersecret',
      }
      class { 'sensu::backend':
        include_default_resources => true,
      }
      EOS

      # There should be no changes as default resources
      # Should not result in changes
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end
  end

  context 'service env_vars' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password       => 'supersecret',
      }
      class { 'sensu::backend':
        service_env_vars => { 'SENSU_BACKEND_AGENT_PORT' => '9081' },
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(9081), :node => node do
      it { should be_listening }
    end
  end

  # This test verifies non-standard location is used by setting agent-port
  # and then checking that port gets used by the daemon
  context 'etc_dir change', if: (['base'].include?(RSpec.configuration.sensu_mode) && pfact_on(node, 'service_provider') == 'systemd') do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        etc_dir        => '/etc/sensugo',
        ssl_dir        => '/etc/sensugo/ssl',
        password       => 'supersecret',
      }
      class { 'sensu::backend':
        config_hash => {
          'agent-port' => 9081,
        },
      }
      EOS

      # Cleanup sensu-backend to verify 'sensu-backend init' works with changed etc_dir
      on node, 'puppet resource service sensu-backend ensure=stopped'
      on node, 'rm -rf /etc/sensu'
      on node, 'rm -rf /root/.config'
      on node, 'rm -rf /var/lib/sensu/sensu-backend/etcd'
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(9081), :node => node do
      it { should be_listening }
    end
  end

  context 'backend and agent' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password       => 'supersecret',
      }
      class { 'sensu::backend': }
      class { 'sensu::agent':
        backends => ['sensu-backend:8081'],
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('sensu-agent'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'backend without agent' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password => 'supersecret',
      }
      class { 'sensu::backend':
        agent_user_disabled => true,
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end
  end

  context 'handles removal of sensuctl config' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password => 'supersecret',
      }
      include sensu::backend
      EOS

      on node, 'rm -rf /root/.config'
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'reset admin password and opt-out tessen' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password       => 'P@ssw0rd!',
      }
      class { 'sensu::backend':
        tessen_ensure => 'absent',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end

    it 'should opt-out of tessen' do
      on node, 'sensuctl tessen info --format json' do
        data = JSON.parse(stdout)
        expect(data['opt_out']).to eq(true)
      end
    end
  end
end
