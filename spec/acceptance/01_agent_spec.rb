require 'spec_helper_acceptance'

describe 'sensu::agent class', unless: RSpec.configuration.sensu_cluster do
  node = only_host_with_role(hosts, 'sensu_agent')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu::agent':
        config_hash => {
          'name'        => 'sensu_agent',
          'backend-url' => 'ws://sensu_backend:8081',
        }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe service('sensu-agent'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
