require 'spec_helper'

describe Puppet::Type.type(:sensu_enterprise_dashboard_api_config) do
  provider_class = described_class.provider(:json)

  let :resource_hash do
    {
      :title   => 'foo.example.com',
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
    it 'port of 4567' do
      expect(type_instance[:port]).to eq('4567')
    end

    it 'timeout of 5' do
      expect(type_instance[:timeout]).to eq('5')
    end
  end

  describe 'host' do
    it 'should be namevar' do
      expect(
        described_class.new(resource_hash).parameters[:host].isnamevar?
      ).to be(true)
    end

    it 'should be title if unspecified' do
      expect(described_class.new(resource_hash)[:host]).to eq('foo.example.com')
    end

    it 'should be host if specified' do
      expect(
        described_class.new(resource_hash.merge(:host => 'api.example.com'))[:host]
      ).to eq('api.example.com')
    end
  end

  describe 'datacenter' do
    it 'should not be namevar' do
      expect(
        described_class.new(resource_hash.merge(:datacenter => 'example1')).parameters[:datacenter].isnamevar?
      ).to_not be(true)
    end
  end

  describe 'ssl' do
    it 'should default to false' do
      expect(described_class.new(resource_hash)[:ssl]).to be(:false)
    end

    it 'should be translated to a symbol (as per PuppetX::Sensu::BooleanProperty)' do
      expect(
        described_class.new(resource_hash.merge(:ssl => 'true'))[:ssl]
      ).to be(:true)
    end
  end

  describe 'insecure' do
    it 'should default to false' do
      expect(described_class.new(resource_hash)[:insecure]).to be(:false)
    end

    it 'should be translated to a symbol (as per PuppetX::Sensu::BooleanProperty)' do
      expect(
        described_class.new(resource_hash.merge(:insecure => 'true'))[:insecure]
      ).to be(:true)
    end
  end
end
