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
    helper.to_type(1).should == 1
  end
  it 'should be callable with string int, and return int' do
    helper.to_type('1').should == 1
  end
  it 'should be callable with string, and return string' do
    helper.to_type('1 foo').should == '1 foo'
  end
  it 'should be callable with false' do
    helper.to_type(false).should == false
  end
  it 'should be callable with true' do
    helper.to_type(true).should == true
  end
  it 'should be callable with nil' do
    helper.to_type(nil).should == nil
  end
  it 'should be callable with array and return munged array' do
    helper.to_type([1, '1', '1 foo', false, true, nil]).should == [1, 1, '1 foo', false, true, nil]
  end
  it 'should be callable with hash and return munged hash' do
    helper.to_type({:a => 1, :b => '1', :c => '1 foo', :d => false, :e => true, :f => nil}).should == {:a => 1, :b => 1, :c => '1 foo', :d => false, :e => true, :f => nil}
  end
  it 'should be able to recurse' do
    helper.to_type({:a => 1, :b => '1', :c => '1 foo', :d => false, :e => true, :f => nil, :g => {:a => 1, :b => '1', :c => '1 foo', :d => false, :e => true, :f => nil}, :h => [1, '1', '1 foo', false, true, nil]}).should == {:a => 1, :b => 1, :c => '1 foo', :d => false, :e => true, :f => nil, :g => {:a => 1, :b => 1, :c => '1 foo', :d => false, :e => true, :f => nil}, :h => [1, 1, '1 foo', false, true, nil]}
  end
end

