require 'spec_helper_acceptance'

describe 'sensu_extension' do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_extension { 'test':
        url => 'http://example.com/extension',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid extension' do
      on node, 'sensuctl extension list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |e| e['name'] == 'test' }
        expect(d[0]['url']).to eq('http://example.com/extension')
      end
    end
  end

  context 'with updates' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_extension { 'test':
        url => 'http://127.0.0.1/extension',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid extension with updated propery' do
      on node, 'sensuctl extension list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |e| e['name'] == 'test' }
        expect(d[0]['url']).to eq('http://127.0.0.1/extension')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_extension { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should not have test extension' do
      on node, 'sensuctl extension list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |e| e['name'] == 'test' }
        expect(d.size).to eq(0)
      end
    end
  end
end

