require 'spec_helper'

describe Puppet::Type.type(:sensu_enterprise_dashboard_config) do
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
    it 'port of 3000' do
      expect(type_instance[:port]).to eq('3000')
    end

    it 'refresh of 5' do
      expect(type_instance[:refresh]).to eq('5')
    end
  end

  describe 'rejects non-Hash values for :github' do
    it 'boolean' do
      expect {
        type_instance[:github] = true
      }.to raise_error Puppet::Error, /must be a Hash/
    end
    it 'string' do
      expect {
        type_instance[:github] = 'test string'
      }.to raise_error Puppet::Error, /must be a Hash/
    end
  end

  describe 'accepts Hash values for :github' do
    it do
      type_instance[:github] = { :key => :value }
      expect(type_instance[:github]).to be_a(Hash)
    end
  end
end
