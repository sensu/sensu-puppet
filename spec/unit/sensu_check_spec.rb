require 'spec_helper'

describe Puppet::Type.type(:sensu_check) do
  let(:resource_hash) do
    {
      :title => 'foo.example.com',
      :catalog => Puppet::Resource::Catalog.new
    }
  end

  describe 'handlers' do
    it 'should support a string as a value' do
      expect(
        described_class.new(resource_hash.merge(:handlers => 'default'))[:handlers]
      ).to eq ['default']
    end

    it 'should support an array as a value' do
      expect(
        described_class.new(
          resource_hash.merge(:handlers => %w(handler1 handler2))
        )[:handlers]
      ).to eq %w(handler1 handler2)
    end

    # it 'should support nil as a value' do
    #   expect(
    #     described_class.new(
    #       resource_hash.merge(:handlers => nil)
    #     )[:handlers]
    #   ).to eq nil
    # end
  end

  describe 'subscribers' do
    it 'should support a string as a value' do
      expect(
        described_class.new(resource_hash.merge(:subscribers => 'default'))[:subscribers]
      ).to eq ['default']
    end

    it 'should support an array as a value' do
      expect(
        described_class.new(
          resource_hash.merge(:subscribers => %w(subscriber1 subscriber2))
        )[:subscribers]
      ).to eq %w(subscriber1 subscriber2)
    end

    # it 'should support nil as a value' do
    #   expect(
    #     described_class.new(
    #       resource_hash.merge(:subscribers => nil)
    #     )[:subscribers]
    #   ).to eq nil
    # end
  end
end
