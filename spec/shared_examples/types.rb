require 'spec_helper'

RSpec.shared_examples 'name_regex' do
  let(:params) { default_params }
  let(:resource) { described_class.new(params) }

  invalid_names = [
    'foo!'
  ]
  valid_names = [
    'foo',
    'foo:',
    'foo-',
    'foo_',
    'foo.example.com',
  ]

  invalid_names.each do |name|
    it "does not allow invalid name #{name}" do
      params[:name] = name
      expect { resource }.to raise_error(/name/)
    end
  end
  valid_names.each do |name|
    it "does allow valid name #{name}" do
      params[:name] = name
      expect { resource }.not_to raise_error
    end
  end
end

RSpec.shared_examples 'autorequires' do |namespace, configure, user|
  namespace = true if namespace.nil?
  configure = true if configure.nil?
  user = true if user.nil?

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
    it 'should autorequire Sensuctl_configure[puppet]' do
      c = Puppet::Type.type(:sensuctl_configure).new(:name => 'puppet', :username => 'admin', :password => 'P@ssw0rd!', :url => 'http://127.0.0.1:8080')
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

  if user
    it 'should autorequire sensu_user' do
      validator = Puppet::Type.type(:sensu_user).new(:name => 'admin', :password => 'password')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource res
      catalog.add_resource validator
      rel = res.autorequire[0]
      expect(rel.source.ref).to eq(validator.ref)
      expect(rel.target.ref).to eq(res.ref)
    end
  end
end
