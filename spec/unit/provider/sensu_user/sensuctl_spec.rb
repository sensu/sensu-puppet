require 'spec_helper'

describe Puppet::Type.type(:sensu_user).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_user)
    @resource = @type.new({
      :name => 'test',
      :password => 'P@ssw0rd!',
    })
    allow(BCrypt::Password).to receive(:create).and_return('$1$hash')
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('user').and_return(my_fixture_read('user_list.json'))
      expect(@provider.instances.length).to eq(3)
    end

    it 'should return the resource for a user' do
      allow(@provider).to receive(:sensuctl_list).with('user').and_return(my_fixture_read('user_list.json'))
      property_hash = @provider.instances.select {|i| i.name == 'admin'}[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('admin')
      expect(property_hash[:roles]).to eq(['admin'])
    end
  end

  describe 'create' do
    it 'should create a user' do
      expected_spec = {
        :name => 'test',
        :password => '$1$hash',
        :disabled => false,
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('user', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create user and reconfigure sensuctl' do
      @resource[:configure] = true
      expected_spec = {
        :name => 'test',
        :password => '$1$hash',
        :disabled => false,
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('user', expected_spec)
      expect(@resource.provider).to receive(:sensuctl).with('configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','P@ssw0rd!')
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a user role' do
      expected_spec = {
        :name => 'test',
        :roles => ['admin'],
        :disabled => false,
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('user', expected_spec)
      @resource.provider.roles = ['admin']
      @resource.provider.flush
    end
    it 'should update a user password' do
      expected_spec = {
        :name => 'test',
        :password => '$1$hash',
        :disabled => false,
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('user', expected_spec)
      @resource.provider.password = 'foobar'
      @resource.provider.flush
    end
    it 'should update a user password and reconfigure' do
      @resource[:configure] = true
      expected_spec = {
        :name => 'test',
        :password => '$1$hash',
        :disabled => false,
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('user', expected_spec)
      expect(@resource.provider).to receive(:sensuctl).with('configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','foobar')
      @resource.provider.password = 'foobar'
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a user' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('user', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

