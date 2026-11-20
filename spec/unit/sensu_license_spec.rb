require 'spec_helper'
require 'puppet/type/sensu_license'

describe Puppet::Type.type(:sensu_license) do
  let(:default_config) do
    {
      name: 'puppet',
      file: '/etc/sensu/license.json',
    }
  end
  let(:config) do
    default_config
  end
  let(:configure) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource configure
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should autorequire file' do
    file = Puppet::Type.type(:file).new(:name => '/etc/sensu/license.json')
    config[:file] = '/etc/sensu/license.json'
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource configure
    catalog.add_resource file
    rel = configure.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(configure.ref)
  end

  include_examples 'autorequires', false, false do
    let(:res) { configure }
  end

  [
    :file,
  ].each do |property|
    it "should require property #{property} when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { configure }.to raise_error(Puppet::Error, /You must provide #{property}/)
    end
    it "should require property #{property} when ensure => absent" do
      config.delete(property)
      config[:ensure] = :absent
      expect { configure }.to raise_error(Puppet::Error, /You must provide #{property}/)
    end
  end
end
