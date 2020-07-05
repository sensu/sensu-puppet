require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensuctl_config) do
  desc <<-DESC
@summary Abstract type to configure other types
**NOTE** This is a private type not intended to be used directly.
DESC

  newparam(:name, :namevar => true) do
    desc "The name of the resource."
  end

  newparam(:chunk_size, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "sensuctl chunk-size"
  end

  newparam(:validate_namespaces, :boolean => true) do
    desc "Determines of namespaces should be validated with sensuctl"
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:path) do
    desc "path to sensuctl"
  end

  # First collect all types with sensuctl provider that come from this module
  # For each sensuctl type, set the class variable 'chunk_size' used by
  # each provider to list resources
  # Return empty array since we are not actually generating resources
  def generate
    sensuctl_types = []
    Dir[File.join(File.dirname(__FILE__), '../provider/sensu_*/sensuctl.rb')].each do |file|
      type = File.basename(File.dirname(file))
      sensuctl_types << type.to_sym
    end
    sensuctl_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:sensuctl)
      provider_class.chunk_size = self[:chunk_size]
      provider_class.validate_namespaces = self[:validate_namespaces]
      provider_class.path = self[:path]
    end
    []
  end
end
