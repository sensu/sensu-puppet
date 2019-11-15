require 'spec_helper'
require_relative '../../tasks/resolve_reference.rb'

describe SensuResolveReference do
  let(:entities) { my_fixture_read('entities1.json') }
  before(:each) do
    allow(described_class).to receive(:sensuctl_entities).and_return(JSON.parse(entities))
  end

  it 'returns all linux entities' do
    expected_targets = [
      {'name' => 'el7-agent.example.com', 'uri' => 'el7-agent.example.com'}
    ]
    params = { 'subscription' => 'linux' }
    targets = described_class.resolve_reference(params)
    expect(targets).to eq(expected_targets)
  end

  it 'returns all linux entities with ipaddress uri and returns name' do
    expected_targets = [
      {'name' => 'el7-agent.example.com', 'uri' => 'el7-agent.example.com'}
    ]
    params = { 'subscription' => 'linux', 'uri_ipaddress' => true }
    targets = described_class.resolve_reference(params)
    expect(targets).to eq(expected_targets)
  end

  it 'returns all linux entities with ipaddress uri and interface_list' do
    expected_targets = [
      {'name' => 'el7-agent.example.com', 'uri' => '192.168.52.11'}
    ]
    params = { 'subscription' => 'linux', 'uri_ipaddress' => true, 'interface_list' => ['eth1'] }
    targets = described_class.resolve_reference(params)
    expect(targets).to eq(expected_targets)
  end

  it 'returns all windows entities' do
    expected_targets = [
      {'name' => 'win2012r2-agent', 'uri' => 'win2012r2-agent'},
      {'name' => 'win2016-agent', 'uri' => 'win2016-agent'},
      {'name' => 'win2016-agent-bolt', 'uri' => 'win2016-agent-bolt'}
    ]
    params = { 'subscription' => 'windows' }
    targets = described_class.resolve_reference(params)
    expect(targets).to eq(expected_targets)
  end

  it 'returns all windows entities with ip addresses' do
    expected_targets = [
      {'name' => 'win2012r2-agent', 'uri' => '192.168.52.24'},
      {'name' => 'win2016-agent', 'uri' => '192.168.52.26'},
      {'name' => 'win2016-agent-bolt', 'uri' => '192.168.52.28'}
    ]
    params = { 'subscription' => 'windows', 'uri_ipaddress' => true, 'interface_list' => ['Ethernet 2']}
    targets = described_class.resolve_reference(params)
    expect(targets).to eq(expected_targets)
  end
end
