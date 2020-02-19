require 'spec_helper'

describe Puppet::Type.type(:sensu_license).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_license) }
  let(:resource) do
    type.new({
      :name => 'puppet',
      :file => '/etc/sensu/license.json',
    })
  end

  describe 'create' do
    it 'should add license' do
      expect(resource.provider).to receive(:sensuctl).with(['create','-f','/etc/sensu/license.json'])
      resource.provider.create
    end
  end

  describe 'destroy' do
    it 'should remove license' do
      expect(resource.provider).to receive(:sensuctl).with(['delete','-f','/etc/sensu/license.json'])
      resource.provider.destroy
    end
  end
end

