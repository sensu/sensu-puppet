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
      allow(resource.provider).to receive(:password_hash).with('P@ssw0rd!').and_return('$2a$10$GbFbz24mWIOiUqYhoG6gj.Q1rsNJF0F82H9r6rhij7UutFn1Xq/fq')
      expected_spec = {
        :username => 'test',
        :groups   => ['test'],
        :password_hash => '$2a$10$GbFbz24mWIOiUqYhoG6gj.Q1rsNJF0F82H9r6rhij7UutFn1Xq/fq',
        :disabled => false,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('User', {}, expected_spec)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create user and reconfigure sensuctl' do
      resource[:configure] = true
      allow(resource.provider).to receive(:password_hash).with('P@ssw0rd!').and_return('$2a$10$GbFbz24mWIOiUqYhoG6gj.Q1rsNJF0F82H9r6rhij7UutFn1Xq/fq')
      expected_spec = {
        :username => 'test',
        :groups   => ['test'],
        :password_hash => '$2a$10$GbFbz24mWIOiUqYhoG6gj.Q1rsNJF0F82H9r6rhij7UutFn1Xq/fq',
        :disabled => false,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('User', {}, expected_spec)
      expect(resource.provider).to receive(:sensuctl).with(['configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','P@ssw0rd!','--trusted-ca-file','/etc/sensu/ssl/ca.crt'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a user password' do
      allow(resource.provider).to receive(:password_hash).with('password').and_return('$2a$10$QByqGyx1jXOnfzKT5dKcYuMlwo4oJc4dujGO4CecXXODaLlHlOzl6')
      expected_spec = {
        :username => 'test',
        :groups   => ['test'],
        :password_hash => '$2a$10$QByqGyx1jXOnfzKT5dKcYuMlwo4oJc4dujGO4CecXXODaLlHlOzl6',
        :disabled => false,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('User', {}, expected_spec)
      resource.provider.password = 'password'
      resource.provider.flush
    end
    it 'should update a user password and reconfigure' do
      resource[:configure] = true
      allow(resource.provider).to receive(:password_hash).with('password').and_return('$2a$10$QByqGyx1jXOnfzKT5dKcYuMlwo4oJc4dujGO4CecXXODaLlHlOzl6')
      expected_spec = {
        :username => 'test',
        :groups   => ['test'],
        :password_hash => '$2a$10$QByqGyx1jXOnfzKT5dKcYuMlwo4oJc4dujGO4CecXXODaLlHlOzl6',
        :disabled => false,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('User', {}, expected_spec)
      expect(resource.provider).to receive(:sensuctl).with(['configure','-n','--url','http://127.0.0.1:8080','--username','test','--password','password','--trusted-ca-file','/etc/sensu/ssl/ca.crt'])
      resource.provider.password = 'password'
      resource.provider.flush
    end
    it 'should disable a user' do
      resource[:disabled] = true
      allow(resource.provider).to receive(:password_hash).with('P@ssw0rd!').and_return('$2a$10$GbFbz24mWIOiUqYhoG6gj.Q1rsNJF0F82H9r6rhij7UutFn1Xq/fq')
      expected_spec = {
        :username => 'test',
        :groups   => ['test'],
        :password_hash => '$2a$10$GbFbz24mWIOiUqYhoG6gj.Q1rsNJF0F82H9r6rhij7UutFn1Xq/fq',
        :disabled => true,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('User', {}, expected_spec)
      resource.provider.disabled = true
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

