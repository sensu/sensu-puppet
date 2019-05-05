require 'spec_helper'
require 'puppet/type/sensu_ldap_auth'

describe Puppet::Type.type(:sensu_ldap_auth) do
  let(:default_config) do
    {
      name: 'ldap',
      servers: [
        {'host' => 'test', 'port' => 389},
      ],
      server_binding: {'test' => {'user_dn' => 'cn=foo','password' => 'foo'}},
      server_group_search: {'test' => {'base_dn' => 'ou=Groups'}},
      server_user_search: {'test' => {'base_dn' => 'ou=People'}},
    }
  end
  let(:config) do
    default_config
  end
  let(:auth) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource auth
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  defaults = {
  }

  # String properties
  [
    :groups_prefix,
    :username_prefix,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(auth[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(auth[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(auth[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
    :name,
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { auth }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(auth[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(auth[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(auth[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(auth[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(auth[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(auth[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(auth[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(auth[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(auth[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(auth[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(auth[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(auth[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(auth[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(auth[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(auth[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(auth[property]).to eq(default_config[property])
      end
    end
  end

  describe 'servers' do
    it 'should accept servers and apply defaults' do
      expected = [{
        'host' => 'test',
        'port' => 389,
        'insecure' => false,
        'security' => 'tls',
        'trusted_ca_file' => '',
        'client_cert_file' => '',
        'client_key_file' => '',
      }]
      expect(auth[:servers]).to eq(expected)
    end
    it 'should be required array of hashes' do
      config[:servers] = ['foo']
      expect { auth }.to raise_error(Puppet::Error, /Each server must be a Hash/)
    end
    it 'should require host' do
      config[:servers] = [{'port' => 389}]
      expect { auth }.to raise_error(Puppet::Error, /server requires key host/)
    end
    it 'should require port' do
      config[:servers] = [{'host' => 'test'}]
      expect { auth }.to raise_error(Puppet::Error, /server requires key port/)
    end
    it 'should not accept invalid key' do
      config[:servers][0]['foo'] = 'bar'
      expect { auth }.to raise_error(Puppet::Error, /is not a valid key for server/)
    end
    it 'should require boolean for insecure' do
      config[:servers] = [{'host' => 'test', 'port' => 389, 'insecure' => 'true'}]
      expect { auth }.to raise_error(Puppet::Error, /server insecure must be a Boolean/)
    end
    it 'should require valid security' do
      config[:servers] = [{'host' => 'test', 'port' => 389, 'security' => 'foo'}]
      expect { auth }.to raise_error(Puppet::Error, /server security must be tls, starttls or insecure/)
    end
  end

  describe 'server_binding' do
    it 'should accept valid value' do
      expect(auth[:server_binding]).to eq({'test' => {'user_dn' => 'cn=foo','password' => 'foo'}})
    end
    it 'should require a hash' do
      config[:server_binding] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    it 'should require a binding hash' do
      config[:server_binding] = { 'foo' => 'bar' }
      expect { auth }.to raise_error(Puppet::Error, /binding must be a Hash/)
    end
    it 'should require user_dn' do
      config[:server_binding] = {'test' => {'password' => 'foo'}}
      expect { auth }.to raise_error(Puppet::Error, /binding requires user_dn/)
    end
    it 'should require password' do
      config[:server_binding] = {'test' => {'user_dn' => 'cn=foo'}}
      expect { auth }.to raise_error(Puppet::Error, /binding requires password/)
    end
    it 'should not accept invalid key' do
      config[:server_binding]['test']['foo'] = 'bar'
      expect { auth }.to raise_error(Puppet::Error, /is not a valid key for binding/)
    end
    it 'should fail if server not defined' do
      config[:server_binding] = {'foo' => {'user_dn' => 'cn=foo','password' => 'foo'}}
      expect { auth }.to raise_error(Puppet::Error, /Server binding for foo not found in servers property/)
    end
    it 'should fail if binding missing' do
      config[:servers] << {'host' => 'foo' , 'port' => 389}
      expect { auth }.to raise_error(Puppet::Error, /server foo has no binding defined/)
    end
  end

  describe 'server_group_search' do
    it 'should accept valid value and apply defaults' do
      expect(auth[:server_group_search]).to eq({'test' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'groupOfNames'}})
    end
    it 'should require a hash' do
      config[:server_group_search] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    it 'should require a group_search hash' do
      config[:server_group_search] = { 'foo' => 'bar' }
      expect { auth }.to raise_error(Puppet::Error, /group_search must be a Hash/)
    end
    it 'should require base_dn' do
      config[:server_group_search] = {'test' => {}}
      expect { auth }.to raise_error(Puppet::Error, /group_search requires base_dn/)
    end
    it 'should not accept invalid key' do
      config[:server_group_search]['test']['foo'] = 'bar'
      expect { auth }.to raise_error(Puppet::Error, /is not a valid key for group_search/)
    end
    it 'should fail if server not defined' do
      config[:server_group_search] = {'foo' => {'base_dn' => 'ou=Groups'}}
      expect { auth }.to raise_error(Puppet::Error, /Server group_search for foo not found in servers property/)
    end
    it 'should fail if group_search missing' do
      config[:servers] << {'host' => 'foo' , 'port' => 389}
      config[:server_binding] = {'test' => {'user_dn' => 'cn=foo','password' => 'foo'}, 'foo' => {'user_dn' => 'cn=foo','password' => 'foo'}}
      expect { auth }.to raise_error(Puppet::Error, /server foo has no group_search defined/)
    end
  end

  describe 'server_user_search' do
    it 'should accept valid value and apply defaults' do
      expect(auth[:server_user_search]).to eq({'test' => {'base_dn' => 'ou=People','attribute' => 'uid','name_attribute' => 'cn','object_class' => 'person'}})
    end
    it 'should require a hash' do
      config[:server_user_search] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    it 'should require a user_search hash' do
      config[:server_user_search] = { 'foo' => 'bar' }
      expect { auth }.to raise_error(Puppet::Error, /user_search must be a Hash/)
    end
    it 'should require base_dn' do
      config[:server_user_search] = {'test' => {}}
      expect { auth }.to raise_error(Puppet::Error, /user_search requires base_dn/)
    end
    it 'should not accept invalid key' do
      config[:server_user_search]['test']['foo'] = 'bar'
      expect { auth }.to raise_error(Puppet::Error, /is not a valid key for user_search/)
    end
    it 'should fail if server not defined' do
      config[:server_user_search] = {'foo' => {'base_dn' => 'ou=People'}}
      expect { auth }.to raise_error(Puppet::Error, /Server user_search for foo not found in servers property/)
    end
    it 'should fail if user_search missing' do
      config[:servers] << {'host' => 'foo' , 'port' => 389}
      config[:server_binding] = {'test' => {'user_dn' => 'cn=foo','password' => 'foo'}, 'foo' => {'user_dn' => 'cn=foo','password' => 'foo'}}
      config[:server_group_search] = {'test' => {'base_dn' => 'ou=Groups'}, 'foo' => {'base_dn' => 'ou=Groups'}}
      expect { auth }.to raise_error(Puppet::Error, /server foo has no user_search defined/)
    end
  end

  include_examples 'autorequires', false do
    let(:res) { auth }
  end

  it 'should autorequire Exec[sensu-add-license]' do
    exec = Puppet::Type.type(:exec).new(:name => 'sensu-add-license', :path => '/usr/bin')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource auth
    catalog.add_resource exec
    rel = auth.autorequire[0]
    expect(rel.source.ref).to eq(exec.ref)
    expect(rel.target.ref).to eq(auth.ref)
  end

  [
    :servers,
    :server_binding,
    :server_group_search,
    :server_user_search,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { auth }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
