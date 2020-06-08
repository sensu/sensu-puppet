require 'spec_helper'

describe Puppet::Type.type(:sensu_user).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_user) }
  let(:resource) do
    type.new({
      :name => 'test',
      :password => 'P@ssw0rd!',
      :groups => ['test'],
      :provider => 'sensu_api',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('users', nil, {:failonfail => false}).and_return(JSON.parse(my_fixture_read('user_list.json')))
      expect(provider.instances.length).to eq(2)
    end

    it 'should return the resource for a user' do
      allow(provider).to receive(:api_request).with('users', nil, {:failonfail => false}).and_return(JSON.parse(my_fixture_read('user_list.json')))
      property_hash = provider.instances.select {|i| i.name == 'admin'}[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('admin')
      expect(property_hash[:groups]).to eq(['cluster-admins'])
    end
  end

  describe 'create' do
    it 'should create a user' do
      data = {
        :username => 'test',
        :password => 'P@ssw0rd!',
        :groups   => ['test'],
        :disabled => false,
      }
      expect(resource.provider).to receive(:api_request).with('users', data, {:method => 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create user and reconfigure sensuctl' do
      resource[:configure] = true
      data = {
        :username => 'test',
        :password => 'P@ssw0rd!',
        :groups   => ['test'],
        :disabled => false,
      }
      expect(resource.provider).to receive(:api_request).with('users', data, {:method => 'post'})
      expect(Puppet::Provider::Sensuctl).to receive(:sensuctl).with(['configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','P@ssw0rd!','--trusted-ca-file','/etc/sensu/ssl/ca.crt'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a user password' do
      data = {
        :username => 'test',
        :password => 'foobar',
        :groups   => ['test'],
        :disabled => false,
      }
      expect(resource.provider).to receive(:api_request).with('users/test', data, {:method => 'put'})
      resource.provider.password = 'foobar'
      resource.provider.flush
    end
    it 'should update a user password and reconfigure' do
      resource[:configure] = true
      data = {
        :username => 'test',
        :password => 'foobar',
        :groups   => ['test'],
        :disabled => false,
      }
      expect(resource.provider).to receive(:api_request).with('users/test', data, {:method => 'put'})
      expect(Puppet::Provider::Sensuctl).to receive(:sensuctl).with(['configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','foobar','--trusted-ca-file','/etc/sensu/ssl/ca.crt'])
      resource.provider.password = 'foobar'
      resource.provider.flush
    end
    it 'should add missing groups' do
      data = {
        :username => 'test',
        :password => 'P@ssw0rd!',
        :groups   => ['admin','test'],
        :disabled => false,
      }
      expect(resource.provider).to receive(:api_request).with('users/test', data, {:method => 'put'})
      resource.provider.groups = ['admin','test']
      resource.provider.flush
    end
    it 'should remove groups' do
      data = {
        :username => 'test',
        :password => 'P@ssw0rd!',
        :groups   => [],
        :disabled => false,
      }
      expect(resource.provider).to receive(:api_request).with('users/test', data, {:method => 'put'})
      resource.provider.groups = []
      resource.provider.flush
    end
    it 'should disable a user' do
      data = {
        :username => 'test',
        :password => 'P@ssw0rd!',
        :groups   => ['test'],
        :disabled => true,
      }
      expect(resource.provider).to receive(:api_request).with('users/test', data, {:method => 'put'})
      resource.provider.disabled = true
      resource.provider.flush
    end
    it 'should disable a user' do
      data = {
        :username => 'test',
        :password => 'P@ssw0rd!',
        :groups   => ['test'],
        :disabled => false,
      }
      expect(resource.provider).to receive(:api_request).with('users/test', data, {:method => 'put'})
      resource.provider.disabled = false
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a user' do
      expect(resource.provider).to receive(:api_request).with('users/test', nil, {:method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

