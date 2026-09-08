require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_plugin) do
  desc <<-DESC
@summary Manages Sensu plugins
@example Install a sensu plugin
  sensu_plugin { 'disk-checks':
    ensure  => 'present',
  }

@example Install specific version of a sensu plugin
  sensu_plugin { 'disk-checks':
    ensure  => 'present',
    version => '4.0.0',
  }

@example Install latest version of a sensu plugin
  sensu_plugin { 'disk-checks':
    ensure  => 'present',
    version => 'latest',
  }

**Autorequires**:
* `Package[sensu-plugins-ruby]`
DESC

  extend PuppetX::Sensu::Type

  ensurable

  newparam(:name, :namevar => true) do
    desc "Plugin or extension name"
    munge do |v|
      n = v.sub('sensu-plugins-', '').sub('sensu-extensions-', '')
      n
    end
  end

  newproperty(:version) do
    desc "Specific version to install, or latest"
    newvalues(:latest, /[0-9\.]+/)
    def insync?(is)
      if @should.is_a?(Array)
        should = @should[0]
      else
        should = @should
      end
      if should == :latest || should == 'latest'
        latest_versions = provider.class.latest_versions
        @latest = latest_versions[@resource.name]
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

  newparam(:extension, :boolean => true) do
    desc "Sets to install an extension instead of a plugin"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:source) do
    desc "Install Sensu plugins and extensions from a custom SOURCE"
  end

  newparam(:clean, :boolean => true) do
    desc "Clean up (remove) other installed versions of the plugin(s) and/or extension(s)"
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:proxy) do
    desc "Install Sensu plugins and extensions via a PROXY URL"
  end

  autorequire(:package) do
    ['sensu-plugins-ruby']
  end
end
