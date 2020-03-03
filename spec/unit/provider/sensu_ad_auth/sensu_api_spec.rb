require 'spec_helper'

describe Puppet::Type.type(:sensu_ad_auth).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_ad_auth) }
  let(:config) do
    {
      :name => 'test',
      :servers => [{
        'host' => 'test', 'port' => 389,
        'binding' => {'user_dn' => 'cn=foo','password' => 'foo'},
        'group_search' => {'base_dn' => 'ou=Groups'},
        'user_search' => {'base_dn' => 'ou=People'},
      }],
      :provider => 'sensu_api',
    }
  end
  let(:resource) do
    type.new(config)
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('authproviders', nil, {:api_group => 'enterprise/authentication'}).and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a auth' do
      allow(provider).to receive(:api_request).with('authproviders', nil, {:api_group => 'enterprise/authentication'}).and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('ad')
    end
  end

  describe 'create' do
    it 'should create an auth' do
      expected_spec = {
        :spec => {
          :servers => [{
            'host' => 'test',
            'port' => 389,
            'insecure' => false,
            'security' => 'tls',
            'trusted_ca_file' => '',
            'client_cert_file' => '',
            'client_key_file' => '',
            'default_upn_domain' => '',
            'binding' => {'user_dn' => 'cn=foo', 'password' => 'foo'},
            'group_search' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'},
            'user_search' => {'base_dn' => 'ou=People','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'},
          }],
        },
        :metadata => {
          :name => 'test',
        },
        :api_version => 'authentication/v2',
        :type => 'ad',
      }
      expect(resource.provider).to receive(:api_request).with('authproviders/test', expected_spec, {:api_group => 'enterprise/authentication', :method => 'put'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create an auth without binding' do
      expected_spec = {
        :spec => {
          :servers => [{
            'host' => 'test',
            'port' => 389,
            'insecure' => false,
            'security' => 'tls',
            'trusted_ca_file' => '',
            'client_cert_file' => '',
            'client_key_file' => '',
            'default_upn_domain' => '',
            'group_search' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'},
            'user_search' => {'base_dn' => 'ou=People','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'},
          }]
        },
        :metadata => {
          :name => 'test',
        },
        :api_version => 'authentication/v2',
        :type => 'ad',
      }
      config[:servers][0].delete('binding')
      expect(resource.provider).to receive(:api_request).with('authproviders/test', expected_spec, {:api_group => 'enterprise/authentication', :method => 'put'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update an auth config' do
      expected_spec = {
        :spec => {
          :servers => [{
            'host' => 'test',
            'port' => 389,
            'insecure' => false,
            'security' => 'tls',
            'trusted_ca_file' => '',
            'client_cert_file' => '',
            'client_key_file' => '',
            'default_upn_domain' => '',
            'binding' => {'user_dn' => 'cn=foo', 'password' => 'bar'},
            'group_search' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'},
            'user_search' => {'base_dn' => 'ou=People','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'},
          }],
          :groups_prefix => nil,
          :username_prefix => nil,
        },
        :metadata => {
          :name => 'test',
        },
        :api_version => 'authentication/v2',
        :type => 'ad',
      }
      config[:servers][0]['binding'] = {'user_dn' => 'cn=foo', 'password' => 'bar'}
      expect(resource.provider).to receive(:api_request).with('authproviders/test', expected_spec, {:api_group => 'enterprise/authentication', :method => 'put'})
      resource.provider.servers = config[:servers]
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete an auth' do
      expect(resource.provider).to receive(:api_request).with('authproviders/test', nil, {:api_group => 'enterprise/authentication', :method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

