begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end
Puppet::Type.newtype(:sensu_filter) do
  @doc = ""

  def initialize(*args)
    super
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
    desc "The name of the filter."
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/filters/'
  end

  newparam(:attributes) do
    desc ""

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

  newproperty(:negate, :boolean => true) do
    desc ""

    newvalues(:true, :false)
  end

  autorequire(:package) do
    ['sensu']
  end
end
