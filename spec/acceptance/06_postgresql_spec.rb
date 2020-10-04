require 'spec_helper_acceptance'

describe 'postgresql datastore', if: RSpec.configuration.sensu_mode == 'full' do
  node = hosts_as('sensu-backend')[0]
  context 'adds postgresql datastore' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { 'postgresql::globals':
        manage_package_repo => true,
        version             => '9.6',
      }
      class { 'postgresql::server':}
      class { 'sensu::backend':
        datastore => 'postgresql',
      }
      EOS
      check_pp = <<-EOS
      sensu_check { 'event-test':
        command       => 'exit 0',
        subscriptions => ['entity:sensu-agent','base'],
        interval      => 1,
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
      apply_manifest_on(node, check_pp, :catch_failures => true)
      on node, 'sensuctl check execute event-test'
    end

    it 'configured postgres' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump store/v1.PostgresConfig --format yaml --all-namespaces' do
        data = YAML.load(stdout)
        expect(data['spec']['dsn']).to eq('postgresql://sensu:changeme@localhost:5432/sensu?sslmode=require')
        expect(data['spec']['pool_size']).to eq(20)
      end
    end

    it 'should have an event' do
      on node, 'sensuctl event info sensu-agent event-test --format json' do
        data = JSON.parse(stdout)
        expect(data['check']['status']).to eq(0)
      end
    end
  end

  context 'updates postgresql datastore' do
    it 'should not expose dsn changes to logs' do
      setup_pp = <<-EOS
      class { 'sensu::backend':
        datastore            => 'postgresql',
        manage_postgresql_db => false,
        postgresql_password  => 'supersecret',
      }
      EOS
      pp = <<-EOS
      class { 'sensu::backend':
        datastore            => 'postgresql',
        manage_postgresql_db => false,
        postgresql_password  => 'foobar',
      }
      EOS
      apply_manifest_on(node, setup_pp, :catch_failures => true)
      result = apply_manifest_on(node, pp, :catch_failures => true)
      expect(result.stdout).not_to include('supersecret')
      expect(result.stderr).not_to include('supersecret')
      expect(result.stdout).not_to include('foobar')
      expect(result.stderr).not_to include('foobar')
    end
  end

  context 'removes postgresql datastore' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { 'sensu::backend':
        datastore        => 'postgresql',
        datastore_ensure => 'absent',
      }
      EOS
      check_pp = <<-EOS
      sensu_check { 'event-test':
        command       => 'exit 0',
        subscriptions => ['entity:sensu-agent'],
        interval      => 1,
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
      apply_manifest_on(node, check_pp, :catch_failures => true)
      on node, 'sensuctl check execute event-test'
    end

    it 'removed postgres config' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump store/v1.PostgresConfig --format yaml --all-namespaces' do
        expect(stdout).to be_empty
      end
    end

    it 'should have an event' do
      on node, 'sensuctl event info sensu-agent event-test --format json' do
        data = JSON.parse(stdout)
        expect(data['check']['status']).to eq(0)
      end
    end
  end
end
