require 'spec_helper'

describe Puppet::Type.type(:sensu_user).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_user) }
  let(:resource) do
    type.new({
      :name => 'test',
      :password => 'P@ssw0rd!',
      :groups => ['test'],
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_list).with('user', false).and_return(JSON.parse(my_fixture_read('user_list.json')))
      expect(provider.instances.length).to eq(2)
    end

    it 'should return the resource for a user' do
      allow(provider).to receive(:sensuctl_list).with('user', false).and_return(JSON.parse(my_fixture_read('user_list.json')))
      property_hash = provider.instances.select {|i| i.name == 'admin'}[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('admin')
      expect(property_hash[:groups]).to eq(['cluster-admins'])
    end
  end

  describe 'create' do
    it 'should create a user' do
      expect(resource.provider).to receive(:sensuctl).with(['user', 'create', 'test', '--password', 'P@ssw0rd!', '--groups', 'test'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create user and reconfigure sensuctl' do
      resource[:configure] = true
      expect(resource.provider).to receive(:sensuctl).with(['user', 'create', 'test', '--password', 'P@ssw0rd!', '--groups', 'test'])
      expect(resource.provider).to receive(:sensuctl).with(['configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','P@ssw0rd!'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    before(:each) do
      hash = resource.provider.instance_variable_get(:@property_hash)
      hash[:groups] = ['admin']
      resource.provider.instance_variable_set(:@property_hash, hash)
    end

    it 'should update a user password' do
      resource[:old_password] = 'foo'
      expect(resource.provider).to receive(:password_insync?).with('test', 'foo').and_return(true)
      expect(resource.provider).to receive(:sensuctl).with(['user', 'change-password', 'test', '--current-password', 'foo', '--new-password', 'foobar'])
      resource.provider.password = 'foobar'
      resource.provider.flush
    end
    it 'should update a user password and reconfigure' do
      resource[:configure] = true
      resource[:old_password] = 'foo'
      expect(resource.provider).to receive(:password_insync?).with('test', 'foo').and_return(true)
      expect(resource.provider).to receive(:sensuctl).with(['user', 'change-password', 'test', '--current-password', 'foo', '--new-password', 'foobar'])
      expect(resource.provider).to receive(:sensuctl).with(['configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','foobar'])
      resource.provider.password = 'foobar'
      resource.provider.flush
    end
    it 'should require old_password to update a user password' do
      resource.provider.password = 'foobar'
      expect { resource.provider.flush }.to raise_error(Puppet::Error, /old_password is manditory when changing a password/)
    end
    it 'should fail if old_password is invalid' do
      resource[:old_password] = 'foo'
      resource.provider.password = 'foobar'
      expect(resource.provider).to receive(:password_insync?).with('test', 'foo').and_return(false)
      expect { resource.provider.flush }.to raise_error(Puppet::Error, /old_password given for test is incorrect/)
    end
    it 'should add missing groups' do
      expect(resource.provider).to receive(:sensuctl).with(['user','add-group','test','test'])
      resource.provider.groups = ['admin','test']
      resource.provider.flush
    end
    it 'should remove groups' do
      expect(resource.provider).to receive(:sensuctl).with(['user','remove-group','test','admin'])
      resource.provider.groups = []
      resource.provider.flush
    end
    it 'should disable a user' do
      resource[:disabled] = false
      expect(resource.provider).to receive(:sensuctl).with(['user','disable','test','--skip-confirm'])
      resource.provider.disabled = true
      resource.provider.flush
    end
    it 'should disable a user' do
      resource[:disabled] = true
      expect(resource.provider).to receive(:sensuctl).with(['user','reinstate','test'])
      resource.provider.disabled = false
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a user' do
      expect(resource.provider).to receive(:sensuctl_delete).with('user', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

