require 'spec_helper'

describe Puppet::Type.type(:sensu_api_config) do
  provider_class = described_class.provider(:json)

  let :resource_hash do
    {
      :title   => 'example api config',
      :catalog => Puppet::Resource::Catalog.new()
    }
  end

  let :type_instance do
    result            = described_class.new(resource_hash)
    provider_instance = provider_class.new(resource_hash)
    result.provider   = provider_instance
    result
  end

  describe 'defaults to' do
    it 'ssl_port => :absent' do
      expect(type_instance[:ssl_port]).to be(:absent)
    end
  end

  context 'when ssl is not set to true' do
    {
      :ssl_port              => 4568,
      :ssl_keystore_file     => '/etc/sensu/ssl/api.keystore',
      :ssl_keystore_password => 'totallysecret'
    }.each do |key, value|
      describe "setting #{key}" do
        it 'should raise an error' do
          ssl_hash = { key => value }
          expect { described_class.new(resource_hash.merge(ssl_hash)) }.
            to raise_error(Puppet::ResourceError)
        end
      end
    end
  end

  context 'when ssl is set to true' do
    {
      :ssl_port              => 4568,
      :ssl_keystore_file     => '/etc/sensu/ssl/api.keystore',
      :ssl_keystore_password => 'totallysecret'
    }.each do |key, value|
      describe "setting #{key}" do
        it 'should not raise an error' do
          ssl_hash = { :ssl => true, key => value }
          expect { described_class.new(resource_hash.merge(ssl_hash)) }.
            to_not raise_error
        end
      end
    end
  end
end
