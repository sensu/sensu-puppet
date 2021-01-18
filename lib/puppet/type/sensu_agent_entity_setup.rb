require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_agent_entity_setup) do
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

  newparam(:agent_managed_entity, :boolean => true) do
    desc "Agent entity managed by agent.yml"
    newvalues(:true, :false)
    defaultto(:false)
  end

  def generate
    [
      Puppet::Type.type(:sensu_agent_entity_config).provider(:sensu_api),
      Puppet::Type.type(:sensu_agent_entity_config).provider(:sensuctl),
    ].each do |provider_class|
      provider_class.url = self[:url]
      provider_class.username = self[:username]
      provider_class.password = self[:password]
      provider_class.agent_managed_entity = self[:agent_managed_entity]
    end
    []
  end
end
