require 'spec_helper'

describe Puppet::Type.type(:sensu_ldap_auth).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_ldap_auth) }
  let(:config) do
    {
      :name => 'test',
      :servers => [{
        'host' => 'test', 'port' => 389,
        'binding' => {'user_dn' => 'cn=foo','password' => 'foo'},
        'group_search' => {'base_dn' => 'ou=Groups'},
        'user_search' => {'base_dn' => 'ou=People'},
      }],
    }
  end
  let(:resource) do
    type.new(config)
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_auth_types).and_return({"activedirectory"=>"AD", "activedirectory2"=>"AD", "openldap"=>"LDAP"})
      allow(provider).to receive(:sensuctl_list).with('auth', false).and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a auth' do
      allow(provider).to receive(:sensuctl_auth_types).and_return({"activedirectory"=>"AD", "activedirectory2"=>"AD", "openldap"=>"LDAP"})
      allow(provider).to receive(:sensuctl_list).with('auth', false).and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('openldap')
    end
  end

  describe 'create' do
    it 'should create an auth' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
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
          'group_search' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'groupOfNames'},
          'user_search' => {'base_dn' => 'ou=People','attribute' => 'uid','name_attribute' => 'cn','object_class' => 'person'},
        }]
      }
      expect(resource.provider).to receive(:sensuctl_create).with('ldap', expected_metadata, expected_spec, 'authentication/v2')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create an auth without binding' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :servers => [{
          'host' => 'test',
          'port' => 389,
          'insecure' => false,
          'security' => 'tls',
          'trusted_ca_file' => '',
          'client_cert_file' => '',
          'client_key_file' => '',
          'default_upn_domain' => '',
          'group_search' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'groupOfNames'},
          'user_search' => {'base_dn' => 'ou=People','attribute' => 'uid','name_attribute' => 'cn','object_class' => 'person'},
        }]
      }
      config[:servers][0].delete('binding')
      expect(resource.provider).to receive(:sensuctl_create).with('ldap', expected_metadata, expected_spec, 'authentication/v2')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update an auth config' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
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
          'group_search' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'groupOfNames'},
          'user_search' => {'base_dn' => 'ou=People','attribute' => 'uid','name_attribute' => 'cn','object_class' => 'person'},
        }],
        :groups_prefix => nil,
        :username_prefix => nil,
      }
      config[:servers][0]['binding'] = {'user_dn' => 'cn=foo', 'password' => 'bar'}
      expect(resource.provider).to receive(:sensuctl_create).with('ldap', expected_metadata, expected_spec, 'authentication/v2')
      resource.provider.servers = config[:servers]
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete an auth' do
      expect(resource.provider).to receive(:sensuctl_delete).with('auth', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

