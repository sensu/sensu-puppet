require 'spec_helper'

describe Puppet::Type.type(:sensuctl_configure).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensuctl_configure) }
  let(:resource) do
    type.new({
      :name => 'puppet',
      :username => 'admin',
      :password => 'foobar',
      :url => 'http://localhost:8080',
    })
  end

  describe 'config_format' do
    it 'should have value' do
      allow(resource.provider).to receive(:sensuctl).with(['config','view','--format','json']).and_return(my_fixture_read('config_list.json'))
      expect(resource.provider.config_format).to eq('tabular')
    end
  end
  describe 'config_namespace' do
    it 'should have value' do
      allow(resource.provider).to receive(:sensuctl).with(['config','view','--format','json']).and_return(my_fixture_read('config_list.json'))
      expect(resource.provider.config_namespace).to eq('default')
    end
  end

  describe 'create' do
    before(:each) do
      allow(resource.provider).to receive(:exists?).and_return(false)
    end

    it 'should run sensuctl configure' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.create
    end
    it 'should run sensuctl configure without SSL' do
      resource[:trusted_ca_file] = 'absent'
      expect(resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.create
    end
    it 'should run sensuctl configure with namespace' do
      resource[:config_namespace] = 'qa'
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      expect(resource.provider).to receive(:sensuctl).with(['config','set-namespace','qa'])
      resource.provider.create
    end
  end

  describe 'flush' do
    before(:each) do
      allow(resource.provider).to receive(:exists?).and_return(true)
    end

    it 'should update a configure' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.url = 'https://localhost:8080'
      resource.provider.flush
    end
    it 'should remove SSL trusted ca' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.trusted_ca_file = 'absent'
      resource.provider.flush
    end
    it 'should use update namespace' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      expect(resource.provider).to receive(:sensuctl).with(['config','set-namespace','qa'])
      resource.provider.config_namespace = 'qa'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should not support deleting a configure' do
      allow(resource.provider).to receive(:config_path).and_return('/root/.config/sensu/sensuctl/cluster')
      expect(File).to receive(:delete).with('/root/.config/sensu/sensuctl/cluster')
      resource.provider.destroy
    end
  end
end

