require 'spec_helper_acceptance'

describe 'sensu::backend class' do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it do
      on node, "/opt/puppetlabs/bin/facter os" do
        puts stdout
      end
    end
    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
