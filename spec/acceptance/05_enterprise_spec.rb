require 'spec_helper_acceptance'

describe 'sensu::backend class', if: RSpec.configuration.sensu_test_enterprise do
  node = hosts_as('sensu_backend')[0]
  context 'adds license file' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { '::sensu::backend':
        password       => 'P@ssw0rd!',
        old_password   => 'supersecret',
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
