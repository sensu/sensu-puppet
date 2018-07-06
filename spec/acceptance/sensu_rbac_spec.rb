# This file contains tests related to RBAC (Role Based Access Controls) resources
# https://docs.sensu.io/sensu-core/2.0/reference/rbac/
# Combining these tests was done to improve overall acceptance test runtime
require 'spec_helper_acceptance'

describe 'sensu RBAC resources' do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_environment { 'test':
        description => 'test',
      }
      sensu_organization { 'test':
        description => 'test',
      }
      sensu_role { 'test':
        rules => [{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read']}]
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid environment' do
      on node, 'sensuctl environment list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['name']).to eq('test')
      end
    end
    it 'should have a valid organization' do
      on node, 'sensuctl organization list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['name']).to eq('test')
      end
    end
    it 'should have a valid role' do
      on node, 'sensuctl role list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['name']).to eq('test')
      end
    end
  end

  context 'update environment' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_environment { 'test':
        description => 'foo',
      }
      sensu_organization { 'test':
        description => 'foo',
      }
      sensu_role { 'test':
        rules => [{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read', 'create']}],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid environment with updated propery' do
      on node, 'sensuctl environment list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['description']).to eq('foo')
      end
    end
    it 'should have a valid organization with updated propery' do
      on node, 'sensuctl organization list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['description']).to eq('foo')
      end
    end
    it 'should have a valid role with updated propery' do
      on node, 'sensuctl role list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['rules'].size).to eq(1)
        expect(d[0]['rules'][0]['permissions']).to eq(['read','create'])
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_environment { 'test': ensure => 'absent' }
      sensu_organization { 'test': ensure => 'absent' }
      sensu_role { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should not have test environment' do
      on node, 'sensuctl environment list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d.size).to eq(0)
      end
    end
    it 'should not have test organization' do
      on node, 'sensuctl organization list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d.size).to eq(0)
      end
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

