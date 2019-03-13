require 'spec_helper'

RSpec.shared_examples 'autorequires' do |namespace, configure|
  namespace = true if namespace.nil?
  configure = true if configure.nil?

  it 'should autorequire Package[sensu-go-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-go-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    catalog.add_resource package
    rel = res.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(res.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    catalog.add_resource service
    rel = res.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(res.ref)
  end

  if configure
    it 'should autorequire Sensu_configure[puppet]' do
      c = Puppet::Type.type(:sensu_configure).new(:name => 'puppet', :username => 'admin', :password => 'P@ssw0rd!', :url => 'http://127.0.0.1:8080')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource res
      catalog.add_resource c
      rel = res.autorequire[0]
      expect(rel.source.ref).to eq(c.ref)
      expect(rel.target.ref).to eq(res.ref)
    end
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    catalog.add_resource validator
    rel = res.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(res.ref)
  end

  if namespace
    it 'should autorequire sensu_namespace' do
      namespace = Puppet::Type.type(:sensu_namespace).new(:name => 'sensu')
      res[:namespace] = 'sensu'
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource res
      catalog.add_resource namespace
      rel = res.autorequire[0]
      expect(rel.source.ref).to eq(namespace.ref)
      expect(rel.target.ref).to eq(res.ref)
    end
  end
end
