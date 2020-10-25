require 'puppet'
require 'puppet/parameter/boolean'
require_relative '../../puppet_x/sensu/agent_entity_config'

Puppet::Type.newtype(:sensu_resources) do
  desc <<-DESC
    @summary Metatype for sensu resources

    @example Purge unmanaged sensu_check resources
      sensu_resources { 'sensu_check':
        purge => true,
      }
  DESC

  newparam(:name) do
    desc "The name of the type to be managed."

    validate do |name|
      raise ArgumentError, _("Only supported with sensu module types") unless name =~ /^sensu_/
      raise ArgumentError, _("Could not find resource type '%{name}'") % { name: name } unless Puppet::Type.type(name)
    end

    munge { |v| v.to_s }
  end

  newparam(:purge, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Whether to purge unmanaged sensu resources.  When set to `true`, this will
      delete any resource that is not specified in your configuration and is not
      autorequired by any managed resources."

    defaultto :false
    newvalues(:true, :false)

    validate do |value|
      if munge(value)
        unless @resource.resource_type.respond_to?(:instances)
          raise ArgumentError, _("Purging resources of type %{res_type} is not supported, since they cannot be queried from the system") % { res_type: @resource[:name] }
        end
        raise ArgumentError, _("Purging is only supported on types that accept 'ensure'") unless @resource.resource_type.validproperty?(:ensure)
      end
    end
  end

  newparam(:agent_entity_configs, :array_matching => :all) do
    desc "Types of configs to purge for sensu_agent_entity_configs, eg ['subscriptions','labels']"

    munge do |value|
      if value.is_a?(String)
        value = [value]
      end
      value
    end
    validate do |values|
      if values.is_a?(String)
        values = [values]
      end
      values.each do |v|
        if ! PuppetX::Sensu::AgentEntityConfig.config_classes.keys.include?(v)
          raise ArgumentError, "#{v} is not a valid sensu_agent_entity_config type of config to purge."
        end
      end
    end
  end

  def able_to_ensure_absent?(resource)
      resource[:ensure] = :absent
  rescue ArgumentError, Puppet::Error
      err _("The 'ensure' attribute on %{name} resources does not accept 'absent' as a value") % { name: self[:name] }
      false
  end

  # Generate any new resources we need to manage.  This is pretty hackish
  # right now, because it only supports purging.
  def generate
    return [] unless self.purge?
    resource_type.instances.
      reject { |r| catalog.resource_refs.include? r.ref }.
      select { |r| check(r) }.
      select { |r| check_agent_entity_config(r) }.
      select { |r| r.class.validproperty?(:ensure) }.
      select { |r| able_to_ensure_absent?(r) }.
      each { |resource|
        @parameters.each do |name, param|
          resource[name] = param.value if param.metaparam?
        end

        # Mark that we're purging, so transactions can handle relationships
        # correctly
        resource.purging
      }
  end

  def resource_type
    unless defined?(@resource_type)
      type = Puppet::Type.type(self[:name])
      unless type
        raise Puppet::DevError, _("Could not find resource type")
      end
      @resource_type = type
    end
    @resource_type
  end

  # Check if name + namespace combination exists in catalog
  def check(resource)
    if resource.class.to_s == 'Puppet::Type::Sensu_agent_entity_config'
      return true
    end
    if ! resource.class.validproperty?(:namespace)
      return true
    end
    namespace = resource[:namespace]
    name = resource[:resource_name] || resource[:name]
    Puppet.debug("sensu_resources check: #{name} in #{namespace}")
    catalog.resources.each do |res|
      if res.class == resource.class
        res_name = res[:resource_name] || res[:name]
        res_namespace = res[:namespace]
        if res_name == name && res_namespace == namespace
          return false
        end
      end
    end
    return true
  end

  def check_agent_entity_config(resource)
    if resource.class.to_s != 'Puppet::Type::Sensu_agent_entity_config'
      return true
    end
    if resource[:key] == 'sensu.io/managed_by'
      return false
    end
    # Do not purge entity subscription as it can not be deleted
    # https://github.com/sensu/sensu-puppet/pull/1280
    if resource[:config] == 'subscriptions' && resource[:value] == "entity:#{resource[:entity]}"
      return false
    end
    if ! self[:agent_entity_configs].nil? && ! self[:agent_entity_configs].include?(resource[:config])
      return false
    end
    catalog.resources.each do |res|
      if res.class != resource.class
        next
      end
      case PuppetX::Sensu::AgentEntityConfig.config_classes[res[:config]]
      when Array
        return false if res[:config] == resource[:config] && res[:value] == resource[:value] && res[:entity] == resource[:entity] && res[:namespace] == resource[:namespace]
      when Hash
        return false if res[:config] == resource[:config] && res[:key] == resource[:key] && res[:entity] == resource[:entity] && res[:namespace] == resource[:namespace]
      else
        return false if res[:config] == resource[:config] && res[:entity] == resource[:entity] && res[:namespace] == resource[:namespace]
      end
    end
    return true
  end

end
