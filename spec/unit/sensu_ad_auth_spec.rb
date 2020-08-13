require 'spec_helper'
require 'puppet/type/sensu_ad_auth'

describe Puppet::Type.type(:sensu_ad_auth) do
  let(:default_config) do
    {
      name: 'ad',
      servers: [{
        'host' => 'test', 'port' => 389,
        'group_search' => {'base_dn' => 'ou=Groups'},
        'user_search' => {'base_dn' => 'ou=People'},
      }],
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

  include_examples 'name_regex' do
    let(:default_params) { default_config }
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
        'default_upn_domain' => '',
        'group_search' => {'base_dn' => 'ou=Groups','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'},
        'user_search' => {'base_dn' => 'ou=People','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'},
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
      config[:servers][0]['insecure'] = 'true'
      expect { auth }.to raise_error(Puppet::Error, /server insecure must be a Boolean/)
    end
    it 'should require valid security' do
      config[:servers][0]['security'] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /server security must be tls, starttls or insecure/)
    end
    it 'should accept valid value for binding' do
      config[:servers][0]['binding'] = {'user_dn' => 'cn=foo','password' => 'foo'}
      expect(auth[:servers][0]['binding']).to eq({'user_dn' => 'cn=foo','password' => 'foo'})
    end
    it 'should require a hash for binding' do
      config[:servers][0]['binding'] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /must be a hash/)
    end
    it 'should require user_dn for binding' do
      config[:servers][0]['binding'] = {'password' => 'foo'}
      expect { auth }.to raise_error(Puppet::Error, /server binding must contain keys/)
    end
    it 'should require password for binding' do
      config[:servers][0]['binding'] = {'user_dn' => 'cn=foo'}
      expect { auth }.to raise_error(Puppet::Error, /server binding must contain keys/)
    end
    it 'should not accept invalid key for binding' do
      config[:servers][0]['binding'] = {'user_dn' => 'cn=foo','password' => 'foo','foo' => 'bar'}
      expect { auth }.to raise_error(Puppet::Error, /server binding must contain keys/)
    end
    it 'should require a hash for group_search' do
      config[:servers][0]['group_search'] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /must be a Hash/)
    end
    it 'should require base_dn for group_search' do
      config[:servers][0]['group_search'] = {}
      expect { auth }.to raise_error(Puppet::Error, /group_search requires base_dn/)
    end
    it 'should not accept invalid key for group_search' do
      config[:servers][0]['group_search'] = {'base_dn' => 'foo', 'foo' => 'bar'}
      expect { auth }.to raise_error(Puppet::Error, /is not a valid key for group_search/)
    end
    it 'should not fail if group_search not defined' do
      config[:servers][0].delete('group_search')
      expect { auth }.not_to raise_error
    end
    it 'should require a hash for user_search' do
      config[:servers][0]['user_search'] = 'foo'
      expect { auth }.to raise_error(Puppet::Error, /must be a Hash/)
    end
    it 'should require base_dn for user_search' do
      config[:servers][0]['user_search'] = {}
      expect { auth }.to raise_error(Puppet::Error, /user_search requires base_dn/)
    end
    it 'should not accept invalid key for user_search' do
      config[:servers][0]['user_search'] = {'base_dn' => 'foo', 'foo' => 'bar'}
      expect { auth }.to raise_error(Puppet::Error, /is not a valid key for user_search/)
    end
    it 'should fail if user_search not defined' do
      config[:servers][0].delete('user_search')
      expect { auth }.to raise_error(Puppet::Error, /requires key user_search/)
    end
  end

  include_examples 'autorequires', false do
    let(:res) { auth }
  end

  [
    :servers,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { auth }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
