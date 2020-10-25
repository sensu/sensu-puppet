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

  describe 'agent_entity_configs' do
    it 'should allow valid values' do
      config[:agent_entity_configs] = ['subscriptions']
      expect(resource[:agent_entity_configs]).to eq(['subscriptions'])
    end
    it 'should allow valid value as string' do
      config[:agent_entity_configs] = 'subscriptions'
      expect(resource[:agent_entity_configs]).to eq(['subscriptions'])
    end
    it 'should not allow invalid values' do
      config[:agent_entity_configs] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, %r{foo is not a valid})
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
    expect(instance_check.purging).to eq(true)
  end

  it 'should not purge sensu_agent_entity_config defined' do
    config[:name] = 'sensu_agent_entity_config'
    agent_config = Puppet::Type.type(:sensu_agent_entity_config).new(:name => 'subscriptions value linux on agent in dev')
    instance_config = Puppet::Type.type(:sensu_agent_entity_config).new(:name => 'subscriptions value linux on agent in dev')
    allow(agent_config.class).to receive(:instances).and_return([instance_config])
    expect(instance_config).not_to receive(:purging)
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource agent_config
    ret = resource.generate
    expect(catalog.resources.size).to eq(2)
    expect(ret).not_to include(instance_config)
  end
  it 'should purge sensu_agent_entity_config not defined' do
    config[:name] = 'sensu_agent_entity_config'
    instance_config = Puppet::Type.type(:sensu_agent_entity_config).new(:name => 'subscriptions value linux on agent in dev')
    allow(instance_config.class).to receive(:instances).and_return([instance_config])
    expect(instance_config).to receive(:purging)
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    ret = resource.generate
    expect(catalog.resources.size).to eq(1)
    expect(ret).to include(instance_config)
  end
  # Do not purge entity subscription as it can not be deleted
  # https://github.com/sensu/sensu-puppet/pull/1280
  it 'should not purge sensu_agent_entity_config for subscription entity' do
    config[:name] = 'sensu_agent_entity_config'
    instance_config = Puppet::Type.type(:sensu_agent_entity_config).new(:name => 'subscriptions value entity:agent on agent in dev')
    allow(instance_config.class).to receive(:instances).and_return([instance_config])
    expect(instance_config).not_to receive(:purging)
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    ret = resource.generate
    expect(catalog.resources.size).to eq(1)
    expect(ret).not_to include(instance_config)
  end
  it 'should not purge sensu_agent_entity_config if config does not match agent_entity_configs' do
    config[:name] = 'sensu_agent_entity_config'
    config[:agent_entity_configs] = ['labels','annotations']
    instance_config = Puppet::Type.type(:sensu_agent_entity_config).new(:name => 'subscriptions value linux on agent in dev')
    allow(instance_config.class).to receive(:instances).and_return([instance_config])
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    ret = resource.generate
    expect(ret).not_to include(instance_config)
  end
  it 'should purge sensu_agent_entity_config not defined with agent_entity_configs defined' do
    config[:name] = 'sensu_agent_entity_config'
    config[:agent_entity_configs] = ['subscriptions']
    instance_config = Puppet::Type.type(:sensu_agent_entity_config).new(:name => 'subscriptions value linux on agent in dev')
    allow(instance_config.class).to receive(:instances).and_return([instance_config])
    expect(instance_config).to receive(:purging)
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    ret = resource.generate
    expect(catalog.resources.size).to eq(1)
    expect(ret).to include(instance_config)
  end
end
