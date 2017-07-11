require 'spec_helper'

describe Puppet::Type.type(:sensu_contact) do
  let(:resource_hash_base) do
    {
      :title => 'support',
      :catalog => Puppet::Resource::Catalog.new
    }
  end
  # This is overridden on a context by context basis
  let(:resource_hash_override) { {} }
  let(:resource_hash) { resource_hash_base.merge(resource_hash_override) }

  describe 'name parameter' do
    subject { described_class.new(resource_hash)[:name] }
    describe 'valid name "support"' do
      it { is_expected.to eq 'support' }
    end
    describe 'invalid name "invalid%name"' do
      let(:resource_hash_override) { {name: 'invalid%name'} }
      it do
        expect { subject }.to raise_error Puppet::ResourceError, /Parameter name failed/
      end
    end
  end

  describe 'notifications' do
    context 'when managing sensu-enterprise (#495)' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-enterprise')
      end
      let(:resource_hash) do
        c = Puppet::Resource::Catalog.new
        c.add_resource(service_resource)
        {
          :title => 'mymutator',
          :catalog => c
        }
      end

      it 'notifies Service[sensu-enterprise]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end
  end
end
