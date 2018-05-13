require 'spec_helper_acceptance'

describe 'sensu_organization', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_organization { 'test':
        description => 'test',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid organization' do
      on node, 'sensuctl organization list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['name']).to eq('test')
      end
    end
  end

  context 'update organization' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_organization { 'test':
        description => 'foo',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid organization with updated propery' do
      on node, 'sensuctl organization list --format json' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['description']).to eq('foo')
      end
    end
  end
end

