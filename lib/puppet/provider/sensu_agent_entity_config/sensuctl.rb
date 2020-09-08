require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../..', 'puppet_x/sensu/agent_entity_config'))

Puppet::Type.type(:sensu_agent_entity_config).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_agent_entity_config using sensuctl"

  mk_resource_methods

  def self.instances
    configs = []

    data = sensuctl_list('entity')

    data.each do |d|
      entity = d['metadata']['name']
      namespace = d['metadata']['namespace']
      PuppetX::Sensu::AgentEntityConfig.config_classes.keys.each do |c|
        value = d[c] || d['metadata'][c]
        next if value.nil?
        case PuppetX::Sensu::AgentEntityConfig.config_classes[c]
        when Array
          value.each do |v|
            config = {}
            config[:ensure] = :present
            config[:entity] = entity
            config[:namespace] = namespace
            config[:config] = c
            config[:value] = v
            config[:name] = "#{config[:config]} value #{config[:value]} on #{entity} in #{namespace}"
            configs << new(config)
          end
        when Hash
          value.each_pair do |key, v|
            config = {}
            config[:ensure] = :present
            config[:entity] = entity
            config[:namespace] = namespace
            config[:config] = c
            config[:key] = key
            config[:value] = v
            config[:name] = "#{config[:config]} key #{config[:key]} on #{entity} in #{namespace}"
            configs << new(config)
          end
        else
          config = {}
          config[:ensure] = :present
          config[:entity] = entity
          config[:namespace] = namespace
          config[:config] = c
          config[:value] = value
          config[:name] = "#{config[:config]} on #{entity} in #{namespace}"
          configs << new(config)
        end
      end
    end
    configs
  end

  def self.prefetch(resources)
    configs = instances
    resources.keys.each do |name|
      if provider = configs.find do |r|
        case PuppetX::Sensu::AgentEntityConfig.config_classes[r.config]
        when Array
          r.config == resources[name][:config] && r.value == resources[name][:value] && r.entity == resources[name][:entity] && r.namespace == resources[name][:namespace]
        when Hash
          r.config == resources[name][:config] && r.key == resources[name][:key] && r.entity == resources[name][:entity] && r.namespace == resources[name][:namespace]
        else
          r.config == resources[name][:config] && r.entity == resources[name][:entity] && r.namespace == resources[name][:namespace]
        end
      end
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  type_properties.each do |prop|
    define_method "#{prop}=".to_sym do |value|
      @property_flush[prop] = value
    end
  end

  def update(add = true)
    entity = get_entity(resource[:entity], resource[:namespace])
    redacted = PuppetX::Sensu::AgentEntityConfig.check_redacted(entity)
    if redacted
      raise Puppet::Error, "Sensu_agent_entity_config[#{resource[:name]}]: Unable to manage resource, REDACTED values detected"
    end
    config = resource[:config]
    if PuppetX::Sensu::AgentEntityConfig.metadata_configs.include?(config)
      obj = entity['metadata'][config]
    else
      obj = entity[config]
    end
    case PuppetX::Sensu::AgentEntityConfig.config_classes[config]
    when Array
      if add && obj.nil?
        obj = []
      end
      if add
        obj << resource[:value]
      else
        obj.delete(resource[:value])
      end
    when Hash
      if add && obj.nil?
        obj = {}
      end
      if add
        obj[resource[:key]] = resource[:value]
      else
        obj.delete(resource[:key])
      end
    else
      if add
        obj = resource[:value]
      else
        obj = ""
      end
    end
    metadata = entity['metadata']
    entity.delete('metadata')
    if PuppetX::Sensu::AgentEntityConfig.metadata_configs.include?(config)
      metadata[config] = obj
    else
      entity[config] = obj
    end
    begin
      sensuctl_create('Entity', metadata, entity)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
  end

  def create
    update
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      update
    end
    @property_hash = resource.to_hash
  end

  def destroy
    update(false)
    @property_hash.clear
  end
end

