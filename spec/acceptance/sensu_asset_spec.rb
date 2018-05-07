require 'spec_helper_acceptance'

describe 'sensu_asset', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_asset { 'test':
        url     => 'http://example.com/asset/example.tar',
        sha512  => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
        filters => ['System.OS==linux'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid asset' do
      on node, 'sensuctl asset info test --format json' do
        data = JSON.parse(stdout)
        expect(data['url']).to eq('http://example.com/asset/example.tar')
      end
    end
  end

  context 'with custom properties' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_asset { 'test':
        url     => 'http://example.com/asset/example.tar',
        sha512  => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
        filters => ['System.OS==linux'],
        custom  => { 'foo' => 'bar' },
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid asset with custom propery' do
      on node, 'sensuctl asset info test --format json' do
        data = JSON.parse(stdout)
        expect(data['foo']).to eq('bar')
      end
    end
  end
end

