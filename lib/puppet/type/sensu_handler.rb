Puppet::Type.newtype(:sensu_handler) do
  @doc = ""

  def initialize(*args)
    super

    self[:notify] = [
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
    desc "The name of the handler"
  end

  newproperty(:type) do
    desc "Type of handler"
  end

  newproperty(:command) do
    desc "Command the handler should run"
  end

  newproperty(:exchange) do
    desc "Exchange information used by the amqp type"
  end

  newproperty(:socket) do
    desc "Socket information used by the udp type"

    def is_to_s(hash = @is)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def should_to_s(hash = @should[0])
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def insync?(is)
      is_to_s(is) == should_to_s
    end

    defaultto {}
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/handlers/'
  end

  newproperty(:mutator) do
    desc "Handler specific data massager"
  end

  newproperty(:filters, :array_matching => :all) do
    desc "Handler filters"
  end

  newproperty(:severities, :array_matching => :all) do
    desc "Severities applicable to this handler"
  end

  newproperty(:handlers, :array_matching => :all) do
    desc "Handlers this handler mutexes into"
  end

  newproperty(:config) do
    desc "Handler specific config"
  end

  autorequire(:package) do
    ['sensu']
  end
end
