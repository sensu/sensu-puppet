require 'spec_helper_acceptance'

describe 'sensu::backend class', unless: RSpec.configuration.sensu_cluster do
  node = hosts_as('sensu_backend')[0]
  before do
    if ! RSpec.configuration.sensu_test_enterprise
      skip("Skipping enterprise tests")
    end
  end
  context 'adds license file' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { 'sensu::backend':
        license_source => '/root/sensu_license.json',
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

    describe command('sensuctl license info'), :node => node do
      its(:exit_status) { should eq 0 }
    end
  end
end
