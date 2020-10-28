require 'spec_helper_acceptance'

describe 'sensu::agent class', if: ['base','full'].include?(RSpec.configuration.sensu_mode) do
  node = hosts_as('sensu-agent')[0]
  backend = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu': }
      class { 'sensu::agent':
        backends         => ['sensu-backend:8081'],
        entity_name      => 'sensu-agent',
        subscriptions    => ['base'],
        labels           => { 'foo' => 'bar' },
        annotations      => { 'contacts' => 'dev@example.com' },
        service_env_vars => { 'SENSU_API_PORT' => '4041' },
        config_hash      => {
          'log-level' => 'info',
          'keepalive-interval' => 30,
        }
      }
      sensu::agent::subscription { 'linux': }
      sensu::agent::label { 'cpu.warning': value => '90' }
      sensu::agent::label { 'cpu.critical': value => '95' }
      sensu::agent::label { 'bar': value => 'baz2', redact => true }
      sensu::agent::annotation { 'foobar': value => 'bar' }
      sensu::agent::annotation { 'cpu.message': value => 'bar' }
      sensu::agent::config_entry { 'keepalive-interval': value => 20 }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
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

    describe file('/etc/sensu/agent.yml'), :node => node do
      expected_content = {
        'backend-url'        => ['wss://sensu-backend:8081'],
        'password'           => 'P@ssw0rd!',
        'name'               => 'sensu-agent',
        'namespace'          => 'default',
        'subscriptions'      => ['base','linux'],
        'labels'             => {
          'foo'          => 'bar',
          'bar'          => 'baz2',
          'cpu.warning'  => '90',
          'cpu.critical' => '95',
        },
        'annotations'        => {
          'contacts'    => 'dev@example.com',
          'cpu.message' => 'bar',
          'foobar'      => 'bar',
        },
        'redact'             => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret','bar'],
        'log-level'          => 'info',
        'trusted-ca-file'    => '/etc/sensu/ssl/ca.crt',
        'keepalive-interval' => 20,
      }
      its(:content_as_yaml) { is_expected.to eq(expected_content) }
    end

    describe service('sensu-agent'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(4041), :node => node do
      it { should be_listening }
    end

    it 'should create an entity' do
      on backend, "sensuctl entity info sensu-agent --format json" do
        data = JSON.parse(stdout)
        expect(data['subscriptions']).to include('base')
        expect(data['subscriptions']).to include('linux')
        expect(data['metadata']['labels']).to include({'foo' => 'bar'})
        expect(data['metadata']['labels']).to include({'bar' => 'REDACTED'})
        expect(data['metadata']['labels']).to include({'cpu.warning' => '90'})
        expect(data['metadata']['labels']).to include({'cpu.critical' => '95'})
        expect(data['metadata']['annotations']).to include({'contacts' => 'dev@example.com'})
        expect(data['metadata']['annotations']).to include({'foobar' => 'bar'})
        expect(data['metadata']['annotations']).to include({'cpu.message' => 'bar'})
      end
    end
  end

  # This test verifies non-standard location is used by setting api-port
  # and then checking that port gets used by the daemon
  context 'etc_dir changed', if: (['base','full'].include?(RSpec.configuration.sensu_mode) && pfact_on(node, 'service_provider') == 'systemd') do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        etc_dir => '/etc/sensugo',
      }
      class { 'sensu::agent':
        backends         => ['sensu-backend:8081'],
        entity_name      => 'sensu-agent',
        subscriptions    => ['base'],
        labels           => { 'foo' => 'bar' },
        annotations      => { 'contacts' => 'dev@example.com' },
        config_hash      => {
          'log-level' => 'info',
          'keepalive-interval' => 30,
          'api-port' => 4041,
        }
      }
      sensu::agent::subscription { 'linux': }
      sensu::agent::label { 'cpu.warning': value => '90' }
      sensu::agent::label { 'cpu.critical': value => '95' }
      sensu::agent::label { 'bar': value => 'baz2', redact => true }
      sensu::agent::annotation { 'foobar': value => 'bar' }
      sensu::agent::annotation { 'cpu.message': value => 'bar' }
      sensu::agent::config_entry { 'keepalive-interval': value => 20 }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
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

    describe service('sensu-agent'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(4041), :node => node do
      it { should be_listening }
    end
  end

  context 'updates' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu': }
      class { 'sensu::agent':
        backends         => ['sensu-backend:8081'],
        entity_name      => 'sensu-agent',
        subscriptions    => ['foo'],
        labels           => { 'foo' => 'bar' },
        annotations      => { 'contacts' => 'ops@example.com' },
        service_env_vars => { 'SENSU_API_PORT' => '4041' },
        config_hash      => {
          'log-level' => 'info',
          'keepalive-interval' => 30,
        }
      }
      sensu::agent::subscription { 'bar': }
      sensu::agent::label { 'cpu.warning': value => '90' }
      sensu::agent::label { 'cpu.critical': value => '95' }
      sensu::agent::label { 'bar': value => 'baz3', redact => true }
      sensu::agent::label { 'baz': value => 'baz' }
      sensu::agent::annotation { 'foobar': value => 'bar' }
      sensu::agent::annotation { 'cpu.message': value => 'baz' }
      sensu::agent::config_entry { 'keepalive-interval': value => 20 }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
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

    describe file('/etc/sensu/agent.yml'), :node => node do
      expected_content = {
        'backend-url'        => ['wss://sensu-backend:8081'],
        'password'           => 'P@ssw0rd!',
        'name'               => 'sensu-agent',
        'namespace'          => 'default',
        'subscriptions'      => ['foo','bar'],
        'labels'             => {
          'foo'          => 'bar',
          'bar'          => 'baz3',
          'baz'          => 'baz',
          'cpu.warning'  => '90',
          'cpu.critical' => '95',
        },
        'annotations'        => {
          'contacts'    => 'ops@example.com',
          'cpu.message' => 'baz',
          'foobar'      => 'bar',
        },
        'redact'             => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret','bar'],
        'log-level'          => 'info',
        'trusted-ca-file'    => '/etc/sensu/ssl/ca.crt',
        'keepalive-interval' => 20,
      }
      its(:content_as_yaml) { is_expected.to eq(expected_content) }
    end

    describe service('sensu-agent'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(4041), :node => node do
      it { should be_listening }
    end

    it 'should update an entity' do
      on backend, "sensuctl entity info sensu-agent --format json" do
        data = JSON.parse(stdout)
        expect(data['subscriptions']).to include('base')
        expect(data['subscriptions']).to include('linux')
        expect(data['subscriptions']).to include('foo')
        expect(data['subscriptions']).to include('bar')
        expect(data['metadata']['labels']).to include({'foo' => 'bar'})
        expect(data['metadata']['labels']).to include({'bar' => 'REDACTED'})
        expect(data['metadata']['labels']).to include({'baz' => 'baz'})
        expect(data['metadata']['labels']).to include({'cpu.warning' => '90'})
        expect(data['metadata']['labels']).to include({'cpu.critical' => '95'})
        expect(data['metadata']['annotations']).to include({'contacts' => 'ops@example.com'})
        expect(data['metadata']['annotations']).to include({'foobar' => 'bar'})
        expect(data['metadata']['annotations']).to include({'cpu.message' => 'baz'})
      end
    end

    it 'removes redact for bar' do
      pp = <<-EOS
      sensu_agent_entity_config { 'redact value bar on sensu-agent in default':
        ensure => 'absent',
      }
      EOS
      apply_manifest_on(node, pp, :catch_failures => true)
    end
    it 'should have previously updated redacted value from refresh of agent.yml' do
      on backend, "sensuctl entity info sensu-agent --format json" do
        data = JSON.parse(stdout)
        expect(data['redact']).not_to include('bar')
        expect(data['metadata']['labels']).to include({'bar' => 'baz3'})
      end
    end
  end

  context 'purging' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu': }
      class { 'sensu::agent':
        backends         => ['sensu-backend:8081'],
        entity_name      => 'sensu-agent',
        subscriptions    => ['foo'],
        labels           => { 'foo' => 'bar', 'bar' => 'baz' },
        annotations      => { 'contacts' => 'ops@example.com' },
        service_env_vars => { 'SENSU_API_PORT' => '4041' },
        config_hash      => {
          'log-level' => 'info',
          'keepalive-interval' => 30,
        }
      }
      sensu::agent::subscription { 'base': }
      sensu::agent::label { 'cpu.warning': value => '90' }
      sensu::agent::label { 'cpu.critical': value => '95' }
      sensu::agent::annotation { 'cpu.message': value => 'baz' }
      sensu::agent::config_entry { 'keepalive-interval': value => 20 }

      sensu_resources { 'sensu_agent_entity_config':
        purge                => true,
        agent_entity_configs => ['subscriptions','labels'],
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
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

    it 'should have an entity' do
      on backend, "sensuctl entity info sensu-agent --format json" do
        data = JSON.parse(stdout)
        expect(data['subscriptions']).to include('base')
        expect(data['subscriptions']).not_to include('linux')
        expect(data['subscriptions']).to include('foo')
        expect(data['subscriptions']).not_to include('bar')
        expect(data['metadata']['labels']).to include({'foo' => 'bar'})
        expect(data['metadata']['labels']).to include({'bar' => 'baz'})
        expect(data['metadata']['labels'].keys).not_to include('baz')
        expect(data['metadata']['labels']).to include({'cpu.warning' => '90'})
        expect(data['metadata']['labels']).to include({'cpu.critical' => '95'})
        expect(data['metadata']['annotations']).to include({'contacts' => 'ops@example.com'})
        expect(data['metadata']['annotations']).to include({'foobar' => 'bar'})
        expect(data['metadata']['annotations']).to include({'cpu.message' => 'baz'})
      end
    end
  end
end
