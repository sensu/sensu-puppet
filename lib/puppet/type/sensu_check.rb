begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end
Puppet::Type.newtype(:sensu_check) do
  @doc = ""

  def initialize(*args)
    super

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

  newproperty(:handlers, :array_matching => :all) do
    desc "List of handlers that responds to this check"
  end

  newproperty(:high_flap_threshold) do
    desc "A host is determined to be flapping when the percent change exceedes this threshold."
  end

  newproperty(:interval) do
    desc "How frequently the check runs in seconds"
  end

  newproperty(:low_flap_threshold) do
    desc "A host is determined to be flapping when the percent change is below this threshold."
  end

  newproperty(:subscribers, :array_matching => :all) do
    desc "Who is subscribed to this check"
  end

  newproperty(:custom) do
    desc "Custom check variables"
    include Puppet_X::Sensu::Totype

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

  newproperty(:standalone, :boolean => true) do
    desc "Whether this is a standalone check"

    newvalues(:true, :false)
  end

  newproperty(:timeout) do
    desc "Check timeout in seconds, after it fails"
  end

  newproperty(:aggregate, :boolean => true) do
    desc "Whether check is aggregate"

    newvalues(:true, :false)
  end

  newproperty(:handle, :boolean => true) do
    desc "Whether check event send to a handler"

    newvalues(:true, :false)
  end

  newproperty(:publish, :boolean => true) do
    desc "Whether check is unpublished"

    newvalues(:true, :false)
  end

  autorequire(:package) do
    ['sensu']
  end
end
