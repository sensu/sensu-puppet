require 'spec_helper_acceptance'

describe 'sensu_user', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test':
        password => 'supersecret',
        groups   => ['read-only'],
      }
      sensu_user { 'test2':
        password => 'supersecret',
        groups   => ['read-only'],
      }
      sensu_user { 'test-api':
        password => 'supersecret',
        groups   => ['read-only'],
        provider => 'sensu_api',
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

    it 'should have a valid user' do
      on node, 'sensuctl user list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['username'] == 'test' }[0]
        expect(d['groups']).to eq(['read-only'])
        expect(d['disabled']).to eq(false)
      end
    end

    it 'should have valid password' do
      exit_code = on(node, 'sensuctl user test-creds test --password supersecret').exit_code
      expect(exit_code).to eq(0)
    end

    it 'should have a valid user using API' do
      on node, 'sensuctl user list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['username'] == 'test-api' }[0]
        expect(d['groups']).to eq(['read-only'])
        expect(d['disabled']).to eq(false)
      end
    end

    it 'should have valid password using API' do
      exit_code = on(node, 'sensuctl user test-creds test-api --password supersecret').exit_code
      expect(exit_code).to eq(0)
    end
  end

  context 'updates user' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test':
        password => 'supersecret2',
        groups   => ['read-only'],
      }
      sensu_user { 'test2':
        password => 'supersecret',
        groups   => ['read-only','admin'],
        disabled => true,
      }
      sensu_user { 'test-api':
        password => 'supersecret2',
        groups   => ['read-only','admin'],
        provider => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        result = on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        result = apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
      expect(result.stdout).not_to include('supersecret')
      expect(result.stderr).not_to include('supersecret')
    end

    it 'should have an updated user' do
      on node, 'sensuctl user list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['username'] == 'test2' }[0]
        expect(d['groups']).to eq(['read-only','admin'])
        expect(d['disabled']).to eq(true)
      end
    end
    it 'should have valid password' do
      exit_code = on(node, 'sensuctl user test-creds test --password supersecret2').exit_code
      expect(exit_code).to eq(0)
    end

    it 'should have an updated user using API' do
      on node, 'sensuctl user list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['username'] == 'test-api' }[0]
        expect(d['groups']).to eq(['read-only','admin'])
        expect(d['disabled']).to eq(false)
      end
    end
    it 'should have valid password using API' do
      exit_code = on(node, 'sensuctl user test-creds test-api --password supersecret2').exit_code
      expect(exit_code).to eq(0)
    end
  end

  context 'updates user password' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test':
        password => 'password3',
        groups   => ['read-only'],
      }
      sensu_user { 'test-api':
        password => 'password3',
        groups   => ['read-only'],
        provider => 'sensu_api',
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

    it 'should have valid password' do
      exit_code = on(node, 'sensuctl user test-creds test --password password3').exit_code
      expect(exit_code).to eq(0)
    end

    it 'should have valid password using API' do
      exit_code = on(node, 'sensuctl user test-creds test-api --password password3').exit_code
      expect(exit_code).to eq(0)
    end
  end

  context 'ensure => absent' do
    it 'should result in error as unsupported' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test': ensure => 'absent' }
      sensu_user { 'test-api': ensure => 'absent', provider => 'sensu_api' }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [1,4,6]
      else
        apply_manifest_on(node, pp, :expect_failures => true)
      end
    end
  end
end
