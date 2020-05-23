require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_bonsai_asset) do
  desc <<-DESC
@summary Manages Sensu Bonsai assets
@example Install a bonsai asset
  sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
    ensure  => 'present',
  }

@example Install specific version of a bonsai asset
  sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
    ensure  => 'present',
    version => '1.2.0',
  }

@example Install latest version of a bonsai asset
  sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
    ensure  => 'present',
    version => 'latest',
  }

@example Install a bonsai asset into `dev` namespace using composite names
  sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler in dev':
    ensure  => 'present',
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable do
    desc "Bonsai asset state for Sensu Go asset"
    self.defaultvalues
    defaultto(:present)
  end
    
  newparam(:name, :namevar => true) do
    desc "Bonsai asset name"
  end

  newparam(:bonsai_namespace, :namevar => true) do
    desc "Bonsai asset namespace"
  end

  newparam(:bonsai_name, :namevar => true) do
    desc "Bonsai asset name"
  end

  newproperty(:version) do
    desc "Specific version to install, or latest"
    # Matches versions like v0.1.0 and 0.1.0
    newvalues(:latest, /^(v)?[0-9\.]+$/)
    def insync?(is)
      if @should.is_a?(Array) && @should.size == 1
        should = @should[0]
      else
        should = @should
      end
      if should == :latest || should == 'latest'
        latest_version = provider.class.latest_version(@resource[:bonsai_namespace], @resource[:bonsai_name])
        @latest = latest_version
        return is == @latest
      else
        super(is)
      end
    end
    def should_to_s(newvalue)
      if @latest
        super(@latest)
      else
        super(newvalue)
      end
    end
  end

  newparam(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this asset belongs to."
    defaultto 'default'
  end

  newparam(:rename) do
    desc "Name for Sensu Go asset"
    defaultto do
      "#{@resource[:bonsai_namespace]}/#{@resource[:bonsai_name]}"
    end
  end

  # Generate sensu_asset resource to avoid resource purging deleting
  # sensu_bonsai_asset resources
  def generate
    resources = []
    if self[:ensure].to_s == 'present'
      asset_opts = {}
      asset_opts[:ensure] = self[:ensure]
      asset_opts[:name] = "#{self[:rename]} in #{self[:namespace]}"
      asset_opts[:namespace] = self[:namespace]
      asset_opts[:require] = "Sensu_bonsai_asset[#{self[:name]}]"
      asset_opts[:bonsai] = true
      asset_opts[:provider] = self[:provider] if self[:provider]
      asset = Puppet::Type.type(:sensu_asset).new(asset_opts)
      resources << asset
    end
    resources
  end

  def self.title_patterns
    [
      [
        /^((\S+)\/(\S+) in (\S+))$/,
        [
          [:name],
          [:bonsai_namespace],
          [:bonsai_name],
          [:namespace],
        ],
      ],
      [
        /^((\S+)\/(\S+))$/,
        [
          [:name],
          [:bonsai_namespace],
          [:bonsai_name],
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

  validate do
    if self[:name] !~ /^(\S+)\/(\S+)$/
      if self[:bonsai_namespace].nil? || self[:bonsai_name].nil?
        fail("Sensu_bonsai_asset[#{self[:name]}] needs to be '<bonsai_namespace>/<bonsai_name>' or bonsai_namespace and bonsai_name properties defined")
      end
    end
  end

  def pre_run_check
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
