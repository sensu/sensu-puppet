require 'spec_helper'
require 'puppet/type/sensu_resources'

describe Puppet::Type.type(:sensu_resources) do
  let(:default_config) do
    {
      name: 'sensu_check',
      purge: true,
    }
  end
  let(:config) do
    default_config
  end
  let(:resource) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not work with other module types' do
    config[:name] = 'sensuclassic_check'
    expect { resource }.to raise_error(Puppet::Error, /Only supported with sensu module types/)
  end

  # Boolean properties
  [
    :purge,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(resource[property]).to eq(true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(resource[property]).to eq(false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(resource[property]).to eq(true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(resource[property]).to eq(false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, /expected a boolean value/)
    end
  end

  it 'should not purge sensu_check defined' do
    config[:name] = 'sensu_check'
    check = Puppet::Type.type(:sensu_check).new(:name => 'test', :command => 'test', :subscriptions => ['test'], :handlers => ['test'], :interval => 60)
    instance_check = Puppet::Type.type(:sensu_check).new(:name => 'test in default', :command => 'test', :subscriptions => ['test'], :handlers => ['test'], :interval => 60)
    allow(check.class).to receive(:instances).and_return([instance_check])
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource check
    resource.generate
    expect(catalog.resources.size).to eq(2)
  end

  it 'should purge sensu_check not defined' do
    config[:name] = 'sensu_check'
    instance_check = Puppet::Type.type(:sensu_check).new(:name => 'test in default', :command => 'test', :subscriptions => ['test'], :handlers => ['test'], :interval => 60)
    allow(instance_check.class).to receive(:instances).and_return([instance_check])
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    resource.generate
    expect(catalog.resources.size).to eq(1)
  end
end
