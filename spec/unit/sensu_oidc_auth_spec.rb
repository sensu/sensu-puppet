require 'spec_helper'
require 'puppet/type/sensu_oidc_auth'

describe Puppet::Type.type(:sensu_oidc_auth) do
  let(:default_config) do
    {
      name: 'oidc',
      client_id: 'id',
      client_secret: 'secret',
      server: 'https://idp.example.com',
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
    disable_offline_access: :false,
  }

  # String properties
  [
    :client_id,
    :client_secret,
    :server,
    :redirect_uri,
    :groups_claim,
    :groups_prefix,
    :username_claim,
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
    :additional_scopes,
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
    :disable_offline_access,
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

  include_examples 'autorequires', false do
    let(:res) { auth }
  end

  [
    :client_id,
    :client_secret,
    :server,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { auth }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
