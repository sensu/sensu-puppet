require 'spec_helper_acceptance'

describe 'sensu::backend class', unless: RSpec.configuration.sensu_cluster do
  node = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password     => 'supersecret',
        old_password => 'P@ssw0rd!',
      }
      class { 'sensu::backend':
        include_default_resources => false,
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

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
    describe package('sensu-go-agent'), :node => node do
      it { should_not be_installed }
    end
  end

  context 'default resources' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password     => 'supersecret',
        old_password => 'P@ssw0rd!',
      }
      class { 'sensu::backend':
        include_default_resources => true,
      }
      EOS

      # There should be no changes as default resources
      # Should not result in changes
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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
        password     => 'supersecret',
        old_password => 'P@ssw0rd!',
      }
      class { 'sensu::backend':
        service_env_vars => { 'SENSU_BACKEND_AGENT_PORT' => '9081' },
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
        password     => 'supersecret',
        old_password => 'P@ssw0rd!',
      }
      class { 'sensu::backend': }
      class { 'sensu::agent':
        backends => ['sensu_backend:8081'],
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

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('sensu-agent'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'reset admin password and opt-out tessen' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        password      => 'P@ssw0rd!',
        old_password  => 'supersecret',
      }
      class { 'sensu::backend':
        tessen_ensure => 'absent',
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
