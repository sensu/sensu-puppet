require 'spec_helper'
require 'puppet_x/sensu/array_of_hashes_property'

describe PuppetX::Sensu::ArrayOfHashesProperty do
  before(:all) do
    Puppet::Type.newtype(:array_of_hashes_property_test) do
      newparam(:name, :namevar => true)
      newproperty(:items, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty)
    end
  end

  let(:type) { Puppet::Type.type(:array_of_hashes_property_test) }
  let(:resource) { type.new(:name => 'test', :items => [{ 'a' => 1 }, { 'b' => 2 }]) }
  let(:property) { resource.property(:items) }

  it 'is in sync when the elements match exactly' do
    expect(property.insync?([{ 'a' => 1 }, { 'b' => 2 }])).to eq true
  end

  it 'is in sync when the elements match but are in a different order' do
    expect(property.insync?([{ 'b' => 2 }, { 'a' => 1 }])).to eq true
  end

  it 'ignores nil values when comparing elements' do
    expect(property.insync?([{ 'a' => 1, 'c' => nil }, { 'b' => 2 }])).to eq true
  end

  it 'is not in sync when an element differs' do
    expect(property.insync?([{ 'a' => 1 }, { 'b' => 3 }])).to eq false
  end

  it 'is not in sync when an element is missing' do
    expect(property.insync?([{ 'a' => 1 }])).to eq false
  end

  it 'falls back to the default comparison when either side is not an Array' do
    non_array_resource = type.new(:name => 'test', :items => [{ 'a' => 1 }])
    property = non_array_resource.property(:items)
    expect(property.insync?(:absent)).to eq false
  end
end
