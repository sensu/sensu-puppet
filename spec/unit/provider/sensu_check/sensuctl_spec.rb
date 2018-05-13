require 'spec_helper'

describe Puppet::Type.type(:sensu_check).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_check)
    @resource = @type.new({
      :name => 'test',
      :command => 'foobar',
      :subscriptions => ['demo'],
      :handlers => ['slack']
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('check').and_return(my_fixture_read('check_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a check' do
      allow(@provider).to receive(:sensuctl_list).with('check').and_return(my_fixture_read('check_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('marketing-site')
    end
  end

=begin
  describe 'self.prefetch' do
    it 'should set provider' do
      allow(@provider).to receive(:sensuctl_list).with('check').and_return(my_fixture_read('check_list.json'))
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
    it 'should create a check' do
      @resource[:command] = 'check_ntp'
      @resource[:handlers] = ['email', 'slack']
      @resource[:stdin] = true
      @resource[:publish] = false
      @resource[:proxy_requests_entity_attributes] = ["entity.Class == 'proxy'"]
      expected_spec = {
        :name => 'test',
        :command => 'check_ntp',
        :subscriptions => ['demo'],
        :handlers => ['email', 'slack'],
        :stdin => true,
        :publish => false,
        :organization => 'default',
        :environment => 'default',
        :proxy_requests => { :entity_attributes => ["entity.Class == 'proxy'"] }
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('check', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a check proxy_requests' do
      @resource[:proxy_requests_splay] = true
      expected_spec = {
        :name => 'test',
        :command => 'foobar',
        :subscriptions => ['demo'],
        :handlers => ['slack'],
        :organization => 'default',
        :environment => 'default',
        :proxy_requests => { :splay => true, :entity_attributes => ["entity.Class == 'proxy'"] }
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('check', expected_spec)
      @resource.provider.proxy_requests_entity_attributes = ["entity.Class == 'proxy'"]
      @resource.provider.flush
    end
    it 'should update a check' do
      expected_spec = {
        :name => 'test',
        :command => 'foobar',
        :subscriptions => ['demo'],
        :handlers => ['slack'],
        :organization => 'default',
        :environment => 'default',
        :interval => 20
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('check', expected_spec)
      @resource.provider.interval = 20
      @resource.provider.flush
    end
    it 'should remove ttl' do
      expected_spec = {
        :name => 'test',
        :command => 'foobar',
        :subscriptions => ['demo'],
        :handlers => ['slack'],
        :organization => 'default',
        :environment => 'default',
        :ttl => nil,
      }
      @resource[:ttl] = 60
      expect(@resource.provider).to receive(:sensuctl_create).with('check', expected_spec)
      @resource.provider.ttl = :absent
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a check' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('check', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

