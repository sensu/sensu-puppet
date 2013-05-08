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

  newproperty(:aggregate, :boolean => true) do
    desc "Enables check aggregation"
    newvalues(:true, :false)
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

  newproperty(:notification) do
    desc "Check description used by many handlers in their notification"
  end

  newproperty(:occurrences) do
    desc "Number of occurrences before a notification is sent"
  end

  newproperty(:refresh) do
    desc "Refresh / Interval is how frequently a handler is fired"
  end

  newproperty(:subscribers, :array_matching => :all) do
    desc "Who is subscribed to this check"
  end

  newproperty(:sla, :array_matching => :all) do
    desc "custom variable for notifu"
  end

  newproperty(:type) do
    desc "What type of check is this"
  end

  newproperty(:config) do
    desc "Check configuration for the client to use"
  end

  newproperty(:standalone, :boolean => true) do
    desc "Whether this is a standalone check"

    newvalues(:true, :false)
  end

  autorequire(:package) do
    ['sensu']
  end
end
