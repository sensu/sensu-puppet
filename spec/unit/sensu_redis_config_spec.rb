require 'spec_helper'

describe Puppet::Type.type(:sensu_redis_config) do
  provider_class = described_class.provider(:json)

  let :resource_hash do
    {
        :title   => 'foo.example.com',
        :catalog => Puppet::Resource::Catalog.new(),
    }
  end

  let :type_instance do
    result = described_class.new(resource_hash)
    provider_instance = provider_class.new(resource_hash)
    result.provider = provider_instance
    result
  end

  describe 'reconnect_on_error property' do
    it 'defaults to false' do
      expect(type_instance[:reconnect_on_error]).to be :false
    end

    [true, :true, 'true', 'True', :yes, 'yes'].each do |v|
      it "accepts #{v.inspect} as true" do
        type_instance[:reconnect_on_error] = v
        expect(type_instance[:reconnect_on_error]).to be :true
      end
    end

    [false, :false, 'false', 'False', :no, 'no'].each do |v|
      it "accepts #{v.inspect} as false" do
        type_instance[:reconnect_on_error] = v
        expect(type_instance[:reconnect_on_error]).to be :false
      end
    end

    it 'rejects "foobar" as a value' do
      expect {
        type_instance[:reconnect_on_error] = 'foobar'
      }.to raise_error Puppet::Error, /expected a boolean value/
    end

  end


end
