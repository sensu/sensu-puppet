require 'spec_helper'

describe Puppet::Type.type(:sensu_oidc_auth).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_oidc_auth) }
  let(:resource) do
    type.new({
      :name => 'oidc',
      :client_id => 'id',
      :client_secret => 'secret',
      :server => 'https://idp.example.com',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_auth_types).and_return({"activedirectory"=>"AD", "activedirectory2"=>"AD", "openldap"=>"LDAP", "oidc" => "OIDC"})
      allow(provider).to receive(:sensuctl_list).with('auth', false).and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a auth' do
      allow(provider).to receive(:sensuctl_auth_types).and_return({"activedirectory"=>"AD", "activedirectory2"=>"AD", "openldap"=>"LDAP", "oidc" => "OIDC"})
      allow(provider).to receive(:sensuctl_list).with('auth', false).and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('oidc')
    end
  end

  describe 'create' do
    it 'should create an auth' do
      expected_metadata = {
        :name => 'oidc',
      }
      expected_spec = {
        :client_id => 'id',
        :client_secret => 'secret',
        :server => 'https://idp.example.com',
      }
      allow(resource.provider).to receive(:version_cmp).and_return(false)
      expect(resource.provider).to receive(:sensuctl_create).with('oidc', expected_metadata, expected_spec, 'authentication/v2')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update an auth config' do
      expected_metadata = {
        :name => 'oidc',
      }
      expected_spec = {
        :client_id => 'id',
        :client_secret => 'secret',
        :server => 'https://idp.example.com',
        :username_claim => 'email',
      }
      allow(resource.provider).to receive(:version_cmp).and_return(false)
      expect(resource.provider).to receive(:sensuctl_create).with('oidc', expected_metadata, expected_spec, 'authentication/v2')
      resource.provider.username_claim = 'email'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete an auth' do
      expect(resource.provider).to receive(:sensuctl_delete).with('auth', 'oidc')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

