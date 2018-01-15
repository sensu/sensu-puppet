require 'spec_helper'

describe Puppet::Type.type(:sensu_client_config) do
  let(:resource_hash_base) do
    {
      :title => 'foo.example.com',
      :catalog => Puppet::Resource::Catalog.new
    }
  end
  # Overridden on a context by context basis
  let(:resource_hash_override) { {} }
  let(:resource_hash) { resource_hash_base.merge(resource_hash_override) }

  describe 'deregister' do
    subject { described_class.new(resource_hash)[:deregister] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    context '=> true' do
      let(:resource_hash_override) { {deregister: true} }
      it { is_expected.to eq(:true) }
    end
    context '=> false' do
      let(:resource_hash_override) { {deregister: false} }
      it { is_expected.to eq(:false) }
    end
  end

  describe 'deregistration' do
    subject { described_class.new(resource_hash)[:deregistration] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    context '=> {}' do
      let(:resource_hash_override) { {deregistration: {}} }
      it { is_expected.to eq({}) }
    end
    context '=> absent' do
      let(:resource_hash_override) { {deregistration: 'absent'} }
      it { is_expected.to eq(:absent) }
    end
  end

  describe 'registration' do
    subject { described_class.new(resource_hash)[:registration] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    context '=> {}' do
      let(:resource_hash_override) { {registration: {}} }
      it { is_expected.to eq({}) }
    end
    context '=> absent' do
      let(:resource_hash_override) { {registration: 'absent'} }
      it { is_expected.to eq(:absent) }
    end
  end

  describe 'notifications' do
    let(:resource_hash) do
      c = Puppet::Resource::Catalog.new
      c.add_resource(service_resource)
      {
        :title => 'foo.example.com',
        :catalog => c
      }
    end

    context 'when managing sensu-client' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-client')
      end
      it 'notifies Service[sensu-api]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end
  end

  describe 'http_socket' do
    subject { described_class.new(resource_hash)[:http_socket] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    http_socket = {
      'bind' => '127.0.0.1',
      'port' => '3031',
      'user' => 'sensu',
      'password' => 'sensu'
    }
    context '=> custom values' do
      let(:resource_hash_override) { {http_socket: http_socket} }
      it { is_expected.to eq(http_socket) }
    end
  end

  describe 'servicenow' do
    subject { described_class.new(resource_hash)[:servicenow] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    servicenow = {
      'configuration_item' => {
        'name' => 'test server',
        'os_version' => '7',
      }
    }
    context '=> custom values' do
      let(:resource_hash_override) { {servicenow: servicenow} }
      it { is_expected.to eq(servicenow) }
    end
  end

  describe 'ec2' do
    subject { described_class.new(resource_hash)[:ec2] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    ec2 = {
      'instance-id' => 'i-424242',
      'allowed_instance_states' => [ 'pending','running','rebooting'],
      'region' => 'us-west-1',
      'access_key_id' => 'AlygD0X6Z4Xr2m3gl70J',
      'secret_access_key' => 'y9Jt5OqNOqdy5NCFjhcUsHMb6YqSbReLAJsy4d6obSZIWySv',
      'timeout' => '30',
    }
    context '=> custom values' do
      let(:resource_hash_override) { {ec2: ec2} }
      it { is_expected.to eq(ec2) }
    end
  end

  describe 'chef' do
    subject { described_class.new(resource_hash)[:chef] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    chef = {
      'nodename' => 'test',
      'endpoint' => 'https://api.chef.io/organizations/example',
      'flavor' => 'enterprise',
      'client' => 'sensu-server',
      'key' => '/etc/chef/i-424242.pem',
      'ssl_verify' => 'false',
      'proxy_address' => 'proxy.example.com',
      'proxy_port' => '8080',
      'proxy_username' => 'chef',
      'proxy_password' => 'secret',
      'timeout' => '30',
    }
    context '=> custom values' do
      let(:resource_hash_override) { {chef: chef} }
      it { is_expected.to eq(chef) }
    end
  end

  describe 'puppet' do
    subject { described_class.new(resource_hash)[:puppet] }
    context 'in the default case' do
      it { is_expected.to be_nil }
    end
    puppet = {
      'nodename' => 'test',
    }
    context '=> custom values' do
      let(:resource_hash_override) { {puppet: puppet} }
      it { is_expected.to eq(puppet) }
    end
  end

end
