require 'spec_helper_acceptance'

describe 'sensu without SSL', if: ['base','full'].include?(RSpec.configuration.sensu_mode) do
  backend = hosts_as('sensu-backend')[0]
  agent = hosts_as('sensu-agent')[0]
  context 'backend' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        use_ssl  => false,
        password => 'P@ssw0rd!',
      }
      class { 'sensu::backend': }
      sensu_entity { 'sensu-agent':
        ensure => 'absent',
      }
      EOS

      # Ensure agent entity doesn't get re-added
      on agent, 'puppet resource service sensu-agent ensure=stopped'
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
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
        backends    => ['sensu-backend:8081'],
        entity_name => 'sensu-agent',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
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

    describe command('sensuctl entity info sensu-agent'), :node => backend do
      its(:exit_status) { should eq 0 }
    end
  end

  context 're-enables SSL' do
    it 'should work without errors' do
      backend_pp = <<-EOS
      class { '::sensu':
        password => 'P@ssw0rd!',
      }
      class { 'sensu::backend': }
      EOS
      apply_manifest_on(backend, backend_pp, :catch_failures => true)
    end
  end
end
