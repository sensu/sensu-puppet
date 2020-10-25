require 'spec_helper'
require 'facter/sensu_puppet_facts'

describe SensuPuppetFacts do
  subject { SensuPuppetFacts }
  before(:each) do
    subject.add_facts
  end
  after(:each) do
    Facter.clear
    Facter.clear_messages
  end

  it 'should have puppet_hostcert defined' do
    Puppet[:hostcert] = '/dne/host.pem'
    expect(Facter.value(:puppet_hostcert)).to eq('/dne/host.pem')
  end

  it 'should have puppet_hostprivkey defined' do
    Puppet[:hostprivkey] = '/dne/host.pem'
    expect(Facter.value(:puppet_hostprivkey)).to eq('/dne/host.pem')
  end

  it 'should have puppet_localcacert defined' do
    Puppet[:localcacert] = '/dne/ca.pem'
    expect(Facter.value(:puppet_localcacert)).to eq('/dne/ca.pem')
  end

  it 'should have puppet_hostcrl defined' do
    Puppet[:hostcrl] = '/dne/crl.pem'
    expect(Facter.value(:puppet_hostcrl)).to eq('/dne/crl.pem')
  end
end
