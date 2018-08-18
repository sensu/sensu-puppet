require 'spec_helper_acceptance'

describe 'sensu_role', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role { 'test':
        rules => [{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read']}]
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid role' do
      on node, 'sensuctl role list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['name']).to eq('test')
      end
    end
  end

  context 'update role' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role { 'test':
        rules => [
          {'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read', 'create']},
          {'type' => '*', 'environment' => 'test', 'organization' => '*', 'permissions' => ['create']},
        ],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid role with updated propery' do
      on node, 'sensuctl role list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['rules'].size).to eq(2)
        expect(d[0]['rules'][0]['permissions']).to eq(['read','create'])
        expect(d[0]['rules'][1]['permissions']).to eq(['create'])
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

    it 'should not have test role' do
      on node, 'sensuctl role list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d.size).to eq(0)
      end
    end
  end
end

