require 'spec_helper'
require 'puppet/type/sensu_tessen'

describe Puppet::Type.type(:sensu_tessen) do
  let(:default_config) do
    {
      name: 'test',
      ensure: 'present',
    }
  end
  let(:config) do
    default_config
  end
  let(:tessen) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource tessen
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  include_examples 'autorequires', false do
    let(:res) { tessen }
  end
end
