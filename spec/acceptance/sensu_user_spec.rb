require 'spec_helper_acceptance'

describe 'sensu_user', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test':
        password => 'password',
        groups   => ['read-only'],
      }
      sensu_user { 'test2':
        password => 'password',
        groups   => ['read-only'],
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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
      exit_code = on(node, 'sensuctl user test-creds test --password password').exit_code
      expect(exit_code).to eq(0)
    end
  end

  context 'updates user' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test':
        password     => 'password2',
        old_password => 'password',
        groups       => ['read-only'],
      }
      sensu_user { 'test2':
        password => 'password',
        groups   => ['read-only','admin'],
        disabled => true,
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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

    it 'should have an updated user' do
      on node, 'sensuctl user list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['username'] == 'test2' }[0]
        expect(d['groups']).to eq(['read-only','admin'])
        expect(d['disabled']).to eq(true)
      end
    end
    it 'should have valid password' do
      exit_code = on(node, 'sensuctl user test-creds test --password password2').exit_code
      expect(exit_code).to eq(0)
    end
  end

  context 'updates user password' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test':
        password     => 'password3',
        old_password => 'password2',
        groups       => ['read-only'],
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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
  end

  context 'invalid old_password' do
    it 'should result in an error' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test':
        password     => 'password2',
        old_password => 'password4',
        groups       => ['read-only'],
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [1,4,6]
      else
        apply_manifest_on(node, pp, :expect_failures => true)
      end
    end
  end

  context 'ensure => absent' do
    it 'should result in error as unsupported' do
      pp = <<-EOS
      include sensu::backend
      sensu_user { 'test': ensure => 'absent' }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [1,4,6]
      else
        apply_manifest_on(node, pp, :expect_failures => true)
      end
    end
  end
end
