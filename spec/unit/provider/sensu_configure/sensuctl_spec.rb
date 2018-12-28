require 'spec_helper'

describe Puppet::Type.type(:sensu_configure).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_configure)
    @resource = @type.new({
      :name => 'puppet',
      :username => 'admin',
      :password => 'foobar',
      :url => 'http://localhost:8080',
    })
  end

  describe 'create' do
    it 'should run sensuctl configure' do
      expect(@resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','P@ssw0rd!'])
      @resource.provider.create
    end
  end

  describe 'flush' do
    it 'should update a configure' do
      expect(@resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      @resource.provider.url = 'https://localhost:8080'
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should not support deleting a configure' do
      allow(File).to receive(:expand_path).with('~').and_return('/root')
      expect(File).to receive(:delete).with('/root/.config/sensu/sensuctl/cluster')
      @resource.provider.destroy
    end
  end
end

