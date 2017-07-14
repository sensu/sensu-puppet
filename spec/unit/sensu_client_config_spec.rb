require 'spec_helper'

describe Puppet::Type.type(:sensu_client_config) do
  let(:resource_hash_base) do
    {
      :title => 'foo.example.com',
      :catalog => Puppet::Resource::Catalog.new
    }
  end
  # Overridden on a context by context basis
  let(:resource_hash_override) { {} }
  let(:resource_hash) { resource_hash_base.merge(resource_hash_override) }

  describe 'deregister' do
    subject { described_class.new(resource_hash)[:deregister] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    context '=> true' do
      let(:resource_hash_override) { {deregister: true} }
      it { is_expected.to eq(:true) }
    end
    context '=> false' do
      let(:resource_hash_override) { {deregister: false} }
      it { is_expected.to eq(:false) }
    end
  end

  describe 'deregistration' do
    subject { described_class.new(resource_hash)[:deregistration] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    context '=> {}' do
      let(:resource_hash_override) { {deregistration: {}} }
      it { is_expected.to eq({}) }
    end
    context '=> absent' do
      let(:resource_hash_override) { {deregistration: 'absent'} }
      it { is_expected.to eq(:absent) }
    end
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

    context 'when managing sensu-client' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-client')
      end
      it 'notifies Service[sensu-api]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end
  end
end
