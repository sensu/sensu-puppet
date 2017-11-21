require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.newtype(:sensu_client_subscription) do
  @doc = "Manages Sensu client subscriptions"

  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-client]",
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
    isnamevar
    desc "The subscription name"
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newparam(:file_name) do
    desc "The name of the client config file"
    defaultto { "subscription_" + resource.name + ".json" }
  end

  newproperty(:subscriptions, :array_matching => :all) do
    desc "Subscriptions included, defaults to resource name"

    defaultto { resource.name }

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def insync?(is)
      Puppet.debug "is: #{is.inspect}, should: #{should.inspect}"
      is.sort == should.sort
    end
  end

  newproperty(:custom) do
    desc "Custom client variables"

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

  autorequire(:package) do
    ['sensu']
  end
end
