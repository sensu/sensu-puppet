require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
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

@exampe Create an asset with multiple builds
  sensu_asset { 'test':
    ensure => 'present',
    builds => [
      {
        "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_amd64.tar.gz",
        "sha512" => "487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d3",
        "filters" => [
          "entity.system.os == 'linux'",
          "entity.system.arch == 'amd64'"
        ]
      },
      {
        "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_armv7.tar.gz",
        "sha512" => "70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68b",
        "filters" => [
          "entity.system.os == 'linux'",
          "entity.system.arch == 'arm'",
          "entity.system.arm_version == 7"
        ]
      },
      {
        "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_windows_amd64.tar.gz",
        "sha512" => "10d6411e5c8bd61349897cf8868087189e9ba59c3c206257e1ebc1300706539cf37524ac976d0ed9c8099bdddc50efadacf4f3c89b04a1a8bf5db581f19c157f",
        "filters" => [
          "entity.system.os == 'windows'",
          "entity.system.arch == 'amd64'"
        ]
      }
    ],
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

  newproperty(:builds, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc <<-EOS
    A list of asset builds used to define multiple artifacts which provide the named asset.

    Keys:
    * url: required
    * sha512: required
    * filters: optional Array
    * headers: optional Hash
    EOS
    validate do |build|
      if ! build.is_a?(Hash)
        raise ArgumentError, "Each build must be a Hash not #{build.class}"
      end
      required_keys = ['url','sha512']
      build_keys = build.keys.map { |k| k.to_s }
      required_keys.each do |k|
        if ! build_keys.include?(k)
          raise ArgumentError, "build requires key #{k}"
        end
      end
      if build['filters'] && ! build['filters'].is_a?(Array)
        raise ArgumentError, "build filters must be an Array not #{build['filters'].class}"
      end
      if build['headers'] && ! build['headers'].is_a?(Hash)
        raise ArgumentError, "build headers must be a Hash not #{build['headers'].class}"
      end
      valid_keys = ['url','sha512','filters','headers']
      build.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for a build"
        end
      end
    end
    munge do |build|
      if ! build.key?('filters')
        build['filters'] = nil
      end
      if ! build.key?('headers')
        build['headers'] = nil
      end
      build
    end
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
    if ! self[:builds]
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
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
