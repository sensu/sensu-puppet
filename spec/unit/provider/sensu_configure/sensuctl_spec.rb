require 'spec_helper'

describe Puppet::Type.type(:sensu_configure).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_configure) }
  let(:resource) do
    type.new({
      :name => 'puppet',
      :username => 'admin',
      :password => 'foobar',
      :url => 'http://localhost:8080',
      :bootstrap => true,
    })
  end

  describe 'create' do
    it 'should run sensuctl configure' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','P@ssw0rd!'])
      resource.provider.create
    end
    it 'should run sensuctl configure without SSL' do
      resource[:trusted_ca_file] = 'absent'
      expect(resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','P@ssw0rd!'])
      resource.provider.create
    end
  end

  describe 'flush' do
    it 'should update a configure' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.url = 'https://localhost:8080'
      resource.provider.flush
    end
    it 'should remove SSL trusted ca' do
      allow(resource.provider).to receive(:config_path).and_return('/root/.config/sensu/sensuctl/cluster')
      expect(resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      expect(File).to receive(:delete).with('/root/.config/sensu/sensuctl/cluster')
      resource.provider.trusted_ca_file = 'absent'
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

