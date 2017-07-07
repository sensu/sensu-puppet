require 'spec_helper'

describe Puppet::Type.type(:sensu_extension) do
  let(:resource_hash) do
    {
      :title => 'Emanon',
      :catalog => Puppet::Resource::Catalog.new
    }
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
          :title => 'Emanon',
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
