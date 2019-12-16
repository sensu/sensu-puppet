require 'spec_helper_acceptance'

describe 'sensu without SSL', unless: RSpec.configuration.sensu_cluster do
  backend = hosts_as('sensu_backend')[0]
  agent = hosts_as('sensu_agent')[0]
  context 'backend' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        use_ssl      => false,
        password     => 'P@ssw0rd!',
        old_password => 'supersecret',
      }
      class { 'sensu::backend': }
      sensu_entity { 'sensu_agent':
        ensure => 'absent',
      }
      EOS

      # Ensure agent entity doesn't get re-added
      on agent, 'puppet resource service sensu-agent ensure=stopped'
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(backend, pp, :catch_failures => true)
        apply_manifest_on(backend, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => backend do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('sensuctl entity list'), :node => backend do
      its(:exit_status) { should eq 0 }
    end
  end

  context 'agent' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        use_ssl => false,
      }
      class { 'sensu::agent':
        backends    => ['sensu_backend:8081'],
        entity_name => 'sensu_agent',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_agent' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(agent, pp, :catch_failures => true)
        apply_manifest_on(agent, pp, :catch_changes  => true)
      end
    end

    describe service('sensu-agent'), :node => agent do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('sensuctl entity info sensu_agent'), :node => backend do
      its(:exit_status) { should eq 0 }
    end
  end
end
