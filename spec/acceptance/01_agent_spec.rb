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
        labels           => { 'foo' => 'bar', 'bar' => 'baz' },
        annotations      => { 'cpu.message' => 'foo' },
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
      sensu::agent::annotation { 'foo': value => 'bar', redact => true }
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
        'subscriptions'      => ['base','linux'],
        'labels'             => {
          'foo'          => 'bar',
          'bar'          => 'baz2',
          'cpu.warning'  => '90',
          'cpu.critical' => '95',
        },
        'annotations'        => {
          'cpu.message' => 'bar',
          'foo'         => 'bar',
        },
        'redact'             => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret','bar','foo'],
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
      end
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
        labels           => { 'foo' => 'bar', 'bar' => 'baz' },
        annotations      => { 'cpu.message' => 'foo' },
        service_env_vars => { 'SENSU_API_PORT' => '4041' },
        config_hash      => {
          'log-level' => 'info',
          'keepalive-interval' => 30,
        }
      }
      sensu::agent::subscription { 'bar': }
      sensu::agent::label { 'cpu.warning': value => '90' }
      sensu::agent::label { 'cpu.critical': value => '95' }
      sensu::agent::label { 'bar': value => 'baz2', redact => true }
      sensu::agent::annotation { 'foo': value => 'bar', redact => true }
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
        'subscriptions'      => ['foo','bar'],
        'labels'             => {
          'foo'          => 'bar',
          'bar'          => 'baz2',
          'cpu.warning'  => '90',
          'cpu.critical' => '95',
        },
        'annotations'        => {
          'cpu.message' => 'bar',
          'foo'         => 'bar',
        },
        'redact'             => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret','bar','foo'],
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
        expect(data['subscriptions']).to include('foo')
        expect(data['subscriptions']).to include('bar')
      end
    end
  end
end
