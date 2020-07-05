require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_api_config) do
  desc <<-DESC
@summary Abstract type to configure other types
**NOTE** This is a private type not intended to be used directly.
DESC

  newparam(:name, :namevar => true) do
    desc "The name of the resource."
  end

  newparam(:url) do
    desc "Sensu API URL"
  end

  newparam(:username) do
    desc "Sensu API username"
  end

  newparam(:password) do
    desc "Sensu API password"
  end

  newparam(:validate_namespaces, :boolean => true) do
    desc "Determines of namespaces should be validated with Sensu API"
    newvalues(:true, :false)
    defaultto(:true)
  end

  # First collect all types with sensu_api provider that come from this module
  # For each sensu_api type, set the class variable 'chunk_size' used by
  # each provider to list resources
  # Return empty array since we are not actually generating resources
  def generate
    sensu_api_types = []
    Dir[File.join(File.dirname(__FILE__), '../provider/sensu_*/sensu_api.rb')].each do |file|
      type = File.basename(File.dirname(file))
      sensu_api_types << type.to_sym
    end
    sensu_api_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:sensu_api)
      provider_class.url = self[:url]
      provider_class.username = self[:username]
      provider_class.password = self[:password]
      provider_class.validate_namespaces = self[:validate_namespaces]
    end
    []
  end
end
