require 'spec_helper_acceptance'

describe 'sensu_asset', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_asset { 'test':
        url      => 'http://example.com/asset/example.tar',
        sha512   => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
        filters  => ['System.OS==linux'],
        metadata => {
          'Content-Type' => 'application/tar',
        },
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
        expect(data['filters']).to eq(['System.OS==linux'])
        expect(data['metadata']).to eq({'Content-Type' => 'application/tar'})
      end
    end
  end

  context 'with updates' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_asset { 'test':
        url      => 'http://example.com/asset/example.zip',
        sha512   => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
        filters  => ['System.OS==windows'],
        metadata => {
          'Content-Type' => 'application/zip',
        },
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid asset with updated propery' do
      on node, 'sensuctl asset info test --format json' do
        data = JSON.parse(stdout)
        expect(data['url']).to eq('http://example.com/asset/example.zip')
        expect(data['filters']).to eq(['System.OS==windows'])
        expect(data['metadata']).to eq({'Content-Type' => 'application/zip'})
      end
    end
  end

  context 'ensure => absent' do
    skip("Not yet implemented https://github.com/sensu/sensu-go/issues/988") do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_asset { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl asset info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
  end
end

