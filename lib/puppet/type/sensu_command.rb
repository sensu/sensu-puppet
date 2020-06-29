require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_command) do
  desc <<-DESC
@summary Manage sensuctl command resources
@example Add sensuctl command from Bonsai asset
  sensu_command { 'command-test':
    ensure      => 'present',
    bonsai_name => 'sensu/command-test',
  }

@example Add command from specific version of a Bonsai asset
  sensu_command { 'command-test':
    ensure         => 'present',
    bonsai_name    => 'sensu/command-test',
    bonsai_version => '0.4.0',
  }

@example Add command from URL
  sensu_command { 'command-test':
    ensure => 'present',
    url    => 'https://github.com/amdprophet/command-test/releases/download/v0.0.4/command-test_0.0.4_linux_amd64.tar.gz',
    sha512 => '67aeba3652def271b1921bc1b4621354ad254c89946ebc8d1e39327f69a902d91f4b0326c9020a4a03e4cfbb718b454b6180f9c39aaff1e60daf6310be66244f'
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensu_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "command name"
  end

  newparam(:bonsai_name) do
    desc "Bonsai asset name"
  end

  newproperty(:bonsai_version) do
    desc "Specific Bonsai asset version to install, or latest"
    newvalues(:latest, /[0-9\.]+/)
    def insync?(is)
      if @should.is_a?(Array) && @should.size == 1
        should = @should[0]
      else
        should = @should
      end
      if should == :latest || should == 'latest'
        latest_version = provider.class.latest_bonsai_version(@resource[:bonsai_name])
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

  newproperty(:url) do
    desc "The URL location of the asset."
  end

  newproperty(:sha512) do
    desc "The checksum of the asset"
  end

  validate do
    if self[:ensure] == :present
      if self[:bonsai_name].nil? && self[:url].nil?
        fail("#{PuppetX::Sensu::Type.error_prefix(self)} requires either bonsai_name or url")
      end
      if self[:bonsai_name] && self[:url]
        fail("#{PuppetX::Sensu::Type.error_prefix(self)} bonsai_name and url are mutually exclusive")
      end
      if self[:url] && self[:sha512].nil?
        fail("#{PuppetX::Sensu::Type.error_prefix(self)} sha512 is required when using url")
      end
    end
  end
end
