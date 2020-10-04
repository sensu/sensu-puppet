require 'spec_helper'

describe Puppet::Type.type(:sensu_oidc_auth).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_oidc_auth) }
  let(:resource) do
    type.new({
      :name => 'oidc',
      :client_id => 'id',
      :client_secret => 'secret',
      :server => 'https://idp.example.com',
      :provider => 'sensu_api',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('authproviders', nil, {:api_group => 'enterprise/authentication'}).and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a auth' do
      allow(provider).to receive(:api_request).with('authproviders', nil, {:api_group => 'enterprise/authentication'}).and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('oidc')
    end
  end

  describe 'create' do
    it 'should create an auth' do
      expected_spec = {
        :spec => {
          :client_id => 'id',
          :client_secret => 'secret',
          :server => 'https://idp.example.com',
        },
        :metadata => {
          :name => 'oidc',
        },
        :api_version => 'authentication/v2',
        :type => 'oidc',
      }
      allow(resource.provider).to receive(:version_cmp).and_return(false)
      expect(resource.provider).to receive(:api_request).with('authproviders/oidc', expected_spec, {:api_group => 'enterprise/authentication', :method => 'put'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update an auth config' do
      expected_spec = {
        :spec => {
          :client_id => 'id',
          :client_secret => 'secret',
          :server => 'https://idp.example.com',
          :username_claim => 'email',
        },
        :metadata => {
          :name => 'oidc',
        },
        :api_version => 'authentication/v2',
        :type => 'oidc',
      }
      allow(resource.provider).to receive(:version_cmp).and_return(false)
      expect(resource.provider).to receive(:api_request).with('authproviders/oidc', expected_spec, {:api_group => 'enterprise/authentication', :method => 'put'})
      resource.provider.username_claim = 'email'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete an auth' do
      expect(resource.provider).to receive(:api_request).with('authproviders/oidc', nil, {:api_group => 'enterprise/authentication', :method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

