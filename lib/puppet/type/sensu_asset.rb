require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_asset) do
  desc <<-DESC
Manages Sensu assets
@example Create an asset
  sensu_asset { 'test':
    ensure  => 'present',
    url     => 'http://example.com/asset/example.tar',
    sha512  => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
    filters => ['System.OS==linux'],
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the asset."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_asset name invalid"
      end
    end
  end

  newproperty(:url) do
    desc "The URL location of the asset."
  end

  newproperty(:sha512) do
    desc "The checksum of the asset"
  end

  newproperty(:metadata, :parent => PuppetX::Sensu::HashProperty) do
    desc "Information about the asset, in the form of key value pairs."
  end

  newproperty(:filters, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "A set of filters used by the agent to determine of the asset should be installed."
    newvalues(/.*/, :absent)
  end

  newproperty(:organization) do
    desc "The Sensu RBAC organization that this asset belongs to."
    defaultto 'default'
  end

  validate do
    required_properties = [
      :url,
      :sha512,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
