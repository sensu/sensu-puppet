require 'spec_helper_acceptance'

describe 'sensu_role', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role { 'test':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid role' do
      on node, 'sensuctl role info test --format json' do
        data = JSON.parse(stdout)
        expect(data['rules']).to eq([{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => nil}])
      end
    end
  end

  context 'update role' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role { 'test':
        rules => [
          {'verbs' => ['get','list'], 'resources' => ['*'], resource_names => ['foo']},
          {'verbs' => ['get','list'], 'resources' => ['checks'], resource_names => ['bar']},
        ],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid role with updated propery' do
      on node, 'sensuctl role info test --format json' do
        data = JSON.parse(stdout)
        expect(data['rules'].size).to eq(2)
        expect(data['rules'][0]).to eq({'verbs' => ['get','list'], 'resources' => ['*'], 'resource_names' => ['foo']})
        expect(data['rules'][1]).to eq({'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['bar']})
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl role info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

