require 'spec_helper_acceptance'

describe 'sensu::agent class', unless: RSpec.configuration.sensu_cluster do
  node = hosts_as('sensu_agent')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu': }
      class { '::sensu::agent':
        backends    => ['sensu_backend:8081'],
        config_hash => {
          'name' => 'sensu_agent',
        }
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_agent' { #{pp} }"
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
  end
end
