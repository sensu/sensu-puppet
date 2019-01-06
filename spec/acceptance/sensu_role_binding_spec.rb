require 'spec_helper_acceptance'

describe 'sensu_role_binding', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role { 'test':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      sensu_role_binding { 'test':
        role_ref => 'test',
        subjects => [{'type' => 'User', 'name' => 'admin'}],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid role_binding' do
      on node, 'sensuctl role-binding info test --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']['name']).to eq('test')
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end
  end

  context 'update role_binding' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role { 'test':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      sensu_role_binding { 'test':
        role_ref => 'test',
        subjects => [{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid role_binding with updated propery' do
      on node, 'sensuctl role-binding info test --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']['name']).to eq('test')
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}])
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_role_binding { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl role-binding info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

