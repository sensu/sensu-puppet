require 'spec_helper'

describe Puppet::Type.type(:sensu_check) do
  let(:resource_hash_base) do
    {
      :title => 'foo.example.com',
      :catalog => Puppet::Resource::Catalog.new
    }
  end
  # Overridden on a context by context basis
  let(:resource_hash_override) { {} }
  let(:resource_hash) { resource_hash_base.merge(resource_hash_override) }

  describe 'contacts parameter' do
    subject { described_class.new(resource_hash)[:contacts] }

    valid = [%w(support), %w(support ops), 'support']
    invalid = [%w(supp%ort), %w(support op$), 'sup%port']

    valid.each do |val|
      describe "valid: contacts => #{val.inspect} " do
        let(:resource_hash_override) { {contacts: val} }
        it { is_expected.to eq [*val] }
      end
    end

    invalid.each do |val|
      describe "invalid: contacts => #{val.inspect}" do
        let(:resource_hash_override) { {contacts: val} }
        it do
          expect { subject }.to raise_error Puppet::ResourceError, /Parameter contacts failed/
        end
      end
    end
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

  describe 'notifications' do
    let(:resource_hash) do
      c = Puppet::Resource::Catalog.new
      c.add_resource(service_resource)
      {
        :title => 'foo.example.com',
        :catalog => c
      }
    end

    context 'when managing sensu-enterprise (#495)' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-enterprise')
      end
      it 'notifies Service[sensu-enterprise]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end

    context 'when managing sensu-api (#600)' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-api')
      end
      it 'notifies Service[sensu-api]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end
  end
end
