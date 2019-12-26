require 'spec_helper'

describe Puppet::Type.type(:sensu_check).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_check) }
  let(:resource) do
    type.new({
      :name => 'test',
      :command => 'foobar',
      :subscriptions => ['demo'],
      :handlers => ['slack'],
      :interval => 60,
      :provider => 'sensu_api',
    })
  end

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('checks', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('check_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a check' do
      allow(provider).to receive(:api_request).with('checks', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('check_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('check-cpu in default')
    end
  end

  describe 'create' do
    it 'should create a check' do
      resource[:command] = 'check_ntp'
      resource[:handlers] = ['email', 'slack']
      resource[:stdin] = true
      resource[:publish] = false
      resource[:proxy_requests] = {'entity_attributes' => ["entity.Class == 'proxy'"]}
      expected_spec = {
        :command => 'check_ntp',
        :subscriptions => ['demo'],
        :handlers => ['email', 'slack'],
        :interval => 60,
        :stdin => true,
        :publish => false,
        :proxy_requests => { "entity_attributes" => ["entity.Class == 'proxy'"], "splay" => false, "splay_coverage" => 0 },
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('checks', expected_spec, {namespace: 'default', method: 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a check proxy_requests' do
      expected_spec = {
        :command => 'foobar',
        :subscriptions => ['demo'],
        :interval => 60,
        :publish => true,
        :stdin => false,
        :handlers => ['slack'],
        :proxy_requests => { "splay" => true, "entity_attributes" => ["entity.Class == 'proxy'"] },
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('checks/test', expected_spec, {namespace: 'default', method: 'put'})
      resource.provider.proxy_requests = {'entity_attributes' => ["entity.Class == 'proxy'"], 'splay' => true}
      resource.provider.flush
    end
    it 'should update a check' do
      expected_spec = {
        :command => 'foobar',
        :subscriptions => ['demo'],
        :publish => true,
        :stdin => false,
        :handlers => ['slack'],
        :interval => 20,
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('checks/test', expected_spec, {namespace: 'default', method: 'put'})
      resource.provider.interval = 20
      resource.provider.flush
    end
    it 'should remove ttl' do
      expected_spec = {
        :command => 'foobar',
        :subscriptions => ['demo'],
        :interval => 60,
        :publish => true,
        :stdin => false,
        :handlers => ['slack'],
        :ttl => nil,
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      resource[:ttl] = 120
      expect(resource.provider).to receive(:api_request).with('checks/test', expected_spec, {namespace: 'default', method: 'put'})
      resource.provider.ttl = :absent
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a check' do
      expect(resource.provider).to receive(:api_request).with('checks/test', nil, {namespace: 'default', method: 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

