require 'spec_helper'

describe Puppet::Type.type(:sensu_environment).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_environment)
    @resource = @type.new({
      :name => 'test',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('environment').and_return(my_fixture_read('environment_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a environment' do
      allow(@provider).to receive(:sensuctl_list).with('environment').and_return(my_fixture_read('environment_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('default')
    end
  end

=begin
  describe 'self.prefetch' do
    it 'should set provider' do
      allow(@provider).to receive(:sensuctl_list).with('environment').and_return(my_fixture_read('environment_list.json'))
      instances = @provider.instances
      resources = {}
      instances.each do |i|
        resources[i[:name]] = i
      end
      resources.each do |name, r|
        expect(r).to receive(:provider=).with(@provider)
      end
      @provider.prefetch(resources)
    end
  end
=end

  describe 'create' do
    it 'should create a environment' do
      expected_spec = {
        :name => 'test',
        :organization => 'default',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('environment', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a organization' do
      expected_spec = {
        :name => 'test',
        :organization => 'test',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('environment', expected_spec)
      @resource.provider.organization = 'test'
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a environment' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('environment', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

