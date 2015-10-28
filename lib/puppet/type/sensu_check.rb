require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.newtype(:sensu_check) do
  @doc = ""

  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-client]",
      "Service[sensu-server]",
    ].select { |ref| catalog.resource(ref) }
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    desc "The name of the check."
  end

  newproperty(:command) do
    desc "Command to be run by the check"
  end

  newproperty(:dependencies, :array_matching => :all) do
    desc "Dependencies of this check"
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:handlers, :array_matching => :all) do
    desc "List of handlers that responds to this check"
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:high_flap_threshold) do
    desc "A host is determined to be flapping when the percent change exceedes this threshold."
  end

  newproperty(:interval) do
    desc "How frequently the check runs in seconds"
  end

  newproperty(:occurrences) do
    desc "The number of event occurrences before the handler should take action."
  end

  newproperty(:refresh) do
    desc "The number of seconds sensu-plugin-aware handlers should wait before taking second action."
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/checks'
  end

  newproperty(:low_flap_threshold) do
    desc "A host is determined to be flapping when the percent change is below this threshold."
  end

  newproperty(:source) do
    desc "The check source, used to create a JIT Sensu client for an external resource (e.g. a network switch)."
  end

  newproperty(:subscribers, :array_matching => :all) do
    desc "Who is subscribed to this check"
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:custom) do
    desc "Custom check variables"
    include PuppetX::Sensu::ToType

    def is_to_s(hash = @is)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def should_to_s(hash = @should)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def insync?(is)
      if defined? @should[0]
        if is == @should[0].each { |k, v| value[k] = to_type(v) }
          true
        else
          false
        end
      else
        true
      end
    end

    defaultto {}
  end

  newproperty(:type) do
    desc "What type of check is this"
  end

  newproperty(:standalone, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Whether this is a standalone check"
  end

  newproperty(:timeout) do
    desc "Check timeout in seconds, after it fails"
  end

  newproperty(:aggregate, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Whether check is aggregate"
  end

  newproperty(:handle, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Whether check event send to a handler"
  end

  newproperty(:publish, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Whether check is unpublished"
  end

  newproperty(:subdue) do
    desc "Check subdue"
  end

  newproperty(:ttl) do
    desc "Check ttl in seconds"
  end

  autorequire(:package) do
    ['sensu']
  end
end
