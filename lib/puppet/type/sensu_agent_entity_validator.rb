Puppet::Type.newtype(:sensu_agent_entity_validator) do
  desc <<-DESC
**NOTE** This is a private type not intended to be used directly.

Verify the specified agent entity exists.

@example Verify agent entity 'sensu-agent' exists
  sensu_api_validator { 'sensu-agent':
    namespace => 'dev',
  }
DESC

  ensurable

  newparam(:name, :namevar => true) do
    desc 'An entity to verify'
  end

  newparam(:namespace) do
    desc 'Namespace of entity'
    defaultto 'default'
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up and deciding that entity does not exist'
    defaultto 10

    validate do |value|
      # This will raise an error if the string is not convertible to an integer
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  autorequire(:service) do
    ['sensu-backend', 'sensu-agent']
  end
end
