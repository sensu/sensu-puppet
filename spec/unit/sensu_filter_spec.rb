require 'spec_helper'

describe Puppet::Type.type(:sensu_filter) do
  # service_resource is context-specific
  let(:resource_hash) do
    c = Puppet::Resource::Catalog.new
    c.add_resource(service_resource)
    {
      :title => 'myfilter',
      :catalog => c
    }
  end

  describe 'notifications' do
    context '(#495) when managing sensu-enterprise' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-enterprise')
      end
      it 'notifies Service[sensu-enterprise]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end

    context '(#562) when managing sensu-server' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-server')
      end
      it 'notifies Service[sensu-server]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end
  end
end
