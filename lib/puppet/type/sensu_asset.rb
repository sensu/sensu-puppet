require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_asset) do
  desc <<-DESC
@summary Manages Sensu assets
@example Create an asset
  sensu_asset { 'test':
    ensure  => 'present',
    url     => 'http://example.com/asset/example.tar',
    sha512  => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
    filters  => ["entity.system.os == 'linux'"],
  }

@example Create an asset with namespace `dev` in the name
  sensu_asset { 'test in dev':
    ensure  => 'present',
    url     => 'http://example.com/asset/example.tar',
    sha512  => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
    filters  => ["entity.system.os == 'linux'"],
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensu_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the asset.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the asset."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_asset name invalid"
      end
    end
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:url) do
    desc "The URL location of the asset."
  end

  newproperty(:sha512) do
    desc "The checksum of the asset"
  end

  newproperty(:filters, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "A set of filters used by the agent to determine of the asset should be installed."
    newvalues(/.*/, :absent)
  end

  newproperty(:headers, :parent => PuppetX::Sensu::HashProperty) do
    desc "HTTP headers to appy to asset retrieval requests."
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this asset belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
  end

  def self.title_patterns
    [
      [
        /^((\S+) in (\S+))$/,
        [
          [:name],
          [:resource_name],
          [:namespace],
        ],
      ],
      [
        /(.*)/,
        [
          [:name],
        ],
      ],
    ]
  end

  def pre_run_check
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
