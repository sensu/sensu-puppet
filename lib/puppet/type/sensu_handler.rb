require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/integer_property'
require_relative '../../puppet_x/sensu/secrets_property'

Puppet::Type.newtype(:sensu_handler) do
  desc <<-DESC
@summary Manages Sensu handlers
@example Create a handler
  sensu_handler { 'test':
    ensure  => 'present',
    type    => 'pipe',
    command => 'notify.rb'
  }

@example Create a handler with namespace `dev` in the name
  sensu_handler { 'test in dev':
    ensure  => 'present',
    type    => 'pipe',
    command => 'notify.rb'
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
* `sensu_filter` - Puppet will autorequire `sensu_filter` resources defined in `filters` property.
* `sensu_mutator` - Puppet will autorequire `sensu_mutator` resource defined for `mutator` property.
* `sensu_handler` - Puppet will autorequire `sensu_handler` resources defined for `handlers` property.
* `sensu_asset` - Puppet will autorequire `sensu_asset` resources defined in `runtime_assets` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the handler.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the handler."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_handler name invalid"
      end
    end
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:type) do
    desc "The handler type."
    newvalues('pipe', 'tcp', 'udp', 'set')
  end

  newproperty(:filters, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu event filters (names) to use when filtering events for the handler."
    newvalues(/.*/, :absent)
  end

  newproperty(:mutator) do
    desc "The Sensu event mutator (name) to use to mutate event data for the handler."
    newvalues(/.*/, :absent)
  end

  newproperty(:timeout, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The handler execution duration timeout in seconds (hard stop)"
    newvalues(/^[0-9]+$/, :absent)
    defaultto do
      if ! @resource[:type].nil? && @resource[:type].to_sym == :tcp
        60
      else
        nil
      end
    end
  end

  newproperty(:command) do
    desc "The handler command to be executed."
    newvalues(/.*/, :absent)
  end

  newproperty(:env_vars, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of environment variables to use with command execution."
    newvalues(/.*/, :absent)
  end

  newproperty(:socket, :parent => PuppetX::Sensu::HashProperty) do
    desc <<-EOS
    The socket definition scope, used to configure the TCP/UDP handler socket.

    Valid keys:
    * host - Required - The socket host address (IP or hostname) to connect to.
    * port - Required - The socket port to connect to.
    EOS
    validate do |value|
      super(value)
      required_keys = ['host','port']
      valid_keys = ['host','port']
      value.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for socket"
        end
      end
      required_keys.each do |key|
        if ! value.key?(key)
          raise ArgumentError, "#{key} is required for socket"
        end
      end
      if ! value['port'].is_a?(Integer)
        raise ArgumentError, "socket.port must be an Integer"
      end
    end
  end

  newproperty(:handlers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu event handlers (names) to use for events using the handler set."
    newvalues(/.*/, :absent)
  end

  newproperty(:runtime_assets, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu assets (names), required at runtime for the execution of the command"
    newvalues(/.*/, :absent)
  end

  newproperty(:secrets, :array_matching => :all, :parent => PuppetX::Sensu::SecretsProperty) do
    desc <<-EOS
    Array of the name/secret pairs to use with command execution.
    Example: [{'name' => 'ANSIBLE_HOST', 'secret' => 'sensu-ansible-host' }]
    EOS
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this handler belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
  end

  autorequire(:sensu_filter) do
    self[:filters]
  end

  autorequire(:sensu_mutator) do
    [ self[:mutator] ]
  end

  autorequire(:sensu_handler) do
    self[:handlers]
  end

  autorequire(:sensu_asset) do
    self[:runtime_assets]
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
      :type,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    if !self[:command] && self[:type] == :pipe
      fail "command must be defined for type pipe"
    end
    if (self[:type] == :tcp || self[:type] == :udp) &&
        !self[:socket]
      fail "socket is required for type tcp or type udp"
    end
    if self[:type] == :set && !self[:handlers]
      fail "handlers must be defined for type set"
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
