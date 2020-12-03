require 'spec_helper'

describe Puppet::Type.type(:sensu_secrets_vault_provider).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_secrets_vault_provider) }
  let(:config) do
    {
      :name => 'vault',
      :address => 'https://vaultserver.example.com:8200',
      :token => 'secret',
      :version => 'v1',
    }
  end
  let(:resource) do
    type.new(config)
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl).with(['dump','secrets/v1.Provider','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.txt'))
      expect(provider.instances.length).to eq(3)
    end

    it 'should return the resource for a check' do
      allow(provider).to receive(:sensuctl).with(['dump','secrets/v1.Provider','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.txt'))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('my_vault')
    end
  end

  describe 'get_token' do
    it 'uses token' do
      expect(resource.provider.get_token).to eq('secret')
    end
    it 'reads token file' do
      allow(File).to receive(:read).with('/token').and_return("foobar\n")
      config.delete(:token)
      config[:token_file] = '/token'
      expect(resource.provider.get_token).to eq('foobar')
    end
  end

  describe 'create' do
    it 'should create a check' do
      expected_metadata = {
        :name => 'vault',
      }
      expected_spec = {
        :client => {
          :address => 'https://vaultserver.example.com:8200',
          :token => 'secret',
          :version => 'v1',
          :max_retries => 2,
          :timeout => '60s',
        }
      }
      expect(resource.provider).to receive(:sensuctl_create).with('VaultProvider', expected_metadata, expected_spec, 'secrets/v1')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a check proxy_requests' do
      expected_metadata = {
        :name => 'vault',
      }
      expected_spec = {
        :client => {
          :address => 'https://vaultserver.example.com:8200',
          :token => 'secret',
          :version => 'v1',
          :max_retries => 2,
          :timeout => '20s',
          :tls => nil,
          :rate_limiter => nil,
        }
      }
      expect(resource.provider).to receive(:sensuctl_create).with('VaultProvider', expected_metadata, expected_spec, 'secrets/v1')
      resource.provider.timeout = '20s'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a check' do
      expected_metadata = {
        :name => 'vault',
      }
      expected_spec = {
        :client => {
          :address => 'https://vaultserver.example.com:8200',
          :token => 'secret',
          :version => 'v1',
          :max_retries => 2,
          :timeout => '60s',
          :tls => nil,
          :rate_limiter => nil,
        }
      }
      expect(resource.provider).to receive(:sensuctl_delete).with('VaultProvider', 'vault', nil, expected_metadata, expected_spec, 'secrets/v1')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

