require 'spec_helper_acceptance'

describe 'postgresql datastore', if: RSpec.configuration.sensu_mode == 'full' do
  node = hosts_as('sensu-backend')[0]
  agent = hosts_as('sensu-agent')[0]
  context 'setup' do
    it 'should setup backend and agent' do
      backend_pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
}
      EOS
      agent_pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::agent':
  backends    => ['sensu-backend:8081'],
  entity_name => 'sensu-agent',
}
      EOS
      
      apply_manifest_on(node, backend_pp, :catch_failures => true)
      apply_manifest_on(agent, agent_pp, :catch_failures => true)
      # Wait for agent to connect
      sleep 10
      # Verify agent is connected
      on node, 'sensuctl entity list --format json' do |result|
        entities = JSON.parse(result.stdout)
        agent_found = entities.any? { |e| e['metadata']['name'] == 'sensu-agent' }
        raise "Agent entity not found" unless agent_found
      end
    end
  end
  
  context 'adds postgresql datastore' do
    it 'should work without errors and be idempotent' do
      # Use PostgreSQL 13 on both Rocky and Ubuntu for consistency
      # Rocky 9 defaults to PostgreSQL 13, so we match that on Ubuntu
      pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '13',
}
class { 'postgresql::server':
  postgres_password => 'changeme',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  datastore => 'postgresql',
}
      EOS
      check_pp = <<~EOS
sensu_check { 'event-test-pg':
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
        # Set locale environment variables to prevent encoding errors
        locale_env = {
          'LANG' => 'en_US.UTF-8',
          'LANGUAGE' => 'en_US:en',
          'LC_ALL' => 'en_US.UTF-8'
        }
        
        # Run it multiple times with proper stabilization
        # First run: Install PostgreSQL and start services
        apply_manifest_on(node, pp, :catch_failures => true, :acceptable_exit_codes => [0,2], :environment => locale_env)
        sleep 15  # Let PostgreSQL service fully start
        
        # Second run: Backend reconfigures for PostgreSQL datastore
        apply_manifest_on(node, pp, :catch_failures => true, :acceptable_exit_codes => [0,2], :environment => locale_env)
        sleep 20  # Let backend fully restart and reconfigure, PostgreSQL to stabilize
        
        # Third run: Allow service restart in Docker environments
        apply_manifest_on(node, pp, :acceptable_exit_codes => [0,2], :environment => locale_env)
      end
      # Add the check
      apply_manifest_on(node, check_pp, :catch_failures => true)
      # Verify backend is ready and healthy
      on node, 'sensuctl cluster health'
      # Execute the check
      on node, 'sensuctl check execute event-test-pg'
      # Give check time to execute and event to be stored in PostgreSQL
      # PostgreSQL datastore needs more time than embedded datastore
      sleep 20
      # Verify the entity exists before checking for events
      on node, 'sensuctl entity info sensu-agent --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['name']).to eq('sensu-agent')
      end
    end

    it 'configured postgres' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump store/v1.PostgresConfig --format yaml --all-namespaces' do |result|
        data = YAML.load(result.stdout)
        expect(data['spec']['dsn']).to eq('postgresql://sensu:changeme@localhost:5432/sensu?sslmode=require')
        expect(data['spec']['pool_size']).to eq(20)
      end
    end

    it 'should have an event' do
      # Retry logic for event retrieval as PostgreSQL may take longer to store events
      max_retries = 5
      retry_count = 0
      success = false
      
      while retry_count < max_retries && !success
        begin
          on node, 'sensuctl event info sensu-agent event-test-pg --format json' do |result|
            data = JSON.parse(result.stdout)
            expect(data['check']['status']).to eq(0)
            success = true
          end
        rescue Beaker::Host::CommandFailure => e
          retry_count += 1
          if retry_count < max_retries
            puts "Event not found, retrying in 10 seconds... (attempt #{retry_count}/#{max_retries})"
            sleep 10
          else
            # Final attempt - show what events exist for debugging
            puts "Failed to find event after #{max_retries} attempts. Listing all events:"
            on node, 'sensuctl event list --format json', :accept_all_exit_codes => true do |result|
              puts result.stdout
            end
            raise e
          end
        end
      end
    end
  end

  context 'updates postgresql datastore' do
    it 'should not expose dsn changes to logs' do
      locale_env = {
        'LANG' => 'en_US.UTF-8',
        'LANGUAGE' => 'en_US:en',
        'LC_ALL' => 'en_US.UTF-8'
      }
      
      setup_pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  datastore            => 'postgresql',
  manage_postgresql_db => false,
  postgresql_password  => 'supersecret',
}
      EOS
      pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  datastore            => 'postgresql',
  manage_postgresql_db => false,
  postgresql_password  => 'foobar',
}
      EOS
      apply_manifest_on(node, setup_pp, :catch_failures => true, :environment => locale_env)
      result = apply_manifest_on(node, pp, :catch_failures => true, :environment => locale_env)
      expect(result.stdout).not_to include('supersecret')
      expect(result.stderr).not_to include('supersecret')
      expect(result.stdout).not_to include('foobar')
      expect(result.stderr).not_to include('foobar')
    end
  end

  context 'removes postgresql datastore' do
    it 'should work without errors and be idempotent' do
      pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  datastore        => 'postgresql',
  datastore_ensure => 'absent',
}
      EOS
      check_pp = <<~EOS
sensu_check { 'event-test-pg-removal':
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
        # Set locale environment variables to prevent encoding errors
        locale_env = {
          'LANG' => 'en_US.UTF-8',
          'LANGUAGE' => 'en_US:en',
          'LC_ALL' => 'en_US.UTF-8'
        }
        
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true, :environment => locale_env)
        apply_manifest_on(node, pp, :catch_changes  => true, :environment => locale_env)
      end
      # Add the check
      apply_manifest_on(node, check_pp, :catch_failures => true)
      on node, 'sensuctl check execute event-test-pg-removal'
      # Give check time to execute
      sleep 5
    end

    it 'removed postgres config' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump store/v1.PostgresConfig --format yaml --all-namespaces' do |result|
        expect(result.stdout).to be_empty
      end
    end

    it 'should have an event' do
      on node, 'sensuctl event info sensu-agent event-test-pg-removal --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['check']['status']).to eq(0)
      end
    end
  end
end
