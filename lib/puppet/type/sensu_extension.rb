require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_extension) do
  desc <<-DESC
Manages Sensu extensions
@example Create an extension
  sensu_extension { 'test':
    ensure => 'present',
    url    => 'http://example.com/extension',
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the extension."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_extension name invalid"
      end
    end
  end

  newproperty(:url) do
    desc "The URL location of the extension."
  end

  newproperty(:namespace) do
    desc "The Sensu RBAC namespace that this extension belongs to."
    defaultto 'default'
  end

  validate do
    required_properties = [
      :url,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
