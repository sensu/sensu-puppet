require 'spec_helper_acceptance'

describe 'sensu_namespace', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_namespace { 'test': ensure => 'present' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid namespace' do
      on node, 'sensuctl namespace list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['name']).to eq('test')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_namespace { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should not have test namespace' do
      on node, 'sensuctl namespace list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d.size).to eq(0)
      end
    end
  end
end

