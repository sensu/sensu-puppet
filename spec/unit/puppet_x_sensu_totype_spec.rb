require 'spec_helper'
begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end

class TotypeFixtureClass
  include Puppet_X::Sensu::Totype
end

describe TotypeFixtureClass do
  let(:helper) { TotypeFixtureClass.new }
  it 'should be callable with int, and return int' do
    expect(helper.to_type(1)).to eq(1)
  end
  it 'should be callable with string int, and return int' do
    expect(helper.to_type('1')).to eq(1)
  end
  it 'should be callable with string, and return string' do
    expect(helper.to_type('1 foo')).to eq('1 foo')
  end
  it 'should be callable with false' do
    expect(helper.to_type(false)).to eq(false)
  end
  it 'should be callable with true' do
    expect(helper.to_type(true)).to eq(true)
  end
  it 'should be callable with nil' do
    expect(helper.to_type(nil)).to eq(nil)
  end
  it 'should be callable with array and return munged array' do
    expect(helper.to_type([1, '1', '1 foo', false, true, nil])).to eq([1, 1, '1 foo', false, true, nil])
  end
  it 'should be callable with hash and return munged hash' do
    expect(helper.to_type({:a => 1, :b => '1', :c => '1 foo', :d => false, :e => true, :f => nil})).to eq({:a => 1, :b => 1, :c => '1 foo', :d => false, :e => true, :f => nil})
  end
  it 'should be able to recurse' do
    expect(helper.to_type({:a => 1, :b => '1', :c => '1 foo', :d => false, :e => true, :f => nil, :g => {:a => 1, :b => '1', :c => '1 foo', :d => false, :e => true, :f => nil}, :h => [1, '1', '1 foo', false, true, nil]})).to eq({:a => 1, :b => 1, :c => '1 foo', :d => false, :e => true, :f => nil, :g => {:a => 1, :b => 1, :c => '1 foo', :d => false, :e => true, :f => nil}, :h => [1, 1, '1 foo', false, true, nil]})
  end
end

