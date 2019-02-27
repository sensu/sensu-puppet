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
      class { '::sensu::backend':
        license_source => '/root/sensu_license.json',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl license info'), :node => node do
      its(:exit_status) { should eq 0 }
    end
  end
end
