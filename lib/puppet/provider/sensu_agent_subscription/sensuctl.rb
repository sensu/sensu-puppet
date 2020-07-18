require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_agent_subscription).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_agent_subscription using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    agent_resources = []

    data = sensuctl_list('entity')

    data.each do |d|
      d['subscriptions'].each do |s|
        agent_resource = {}
        agent_resource[:ensure] = :present
        agent_resource[:subscription] = s
        agent_resource[:entity] = d['metadata']['name']
        agent_resource[:namespace] = d['metadata']['namespace']
        agent_resource[:name] = "#{agent_resource[:subscription]} on #{agent_resource[:entity]} in #{agent_resource[:namespace]}"
        agent_resources << new(agent_resource)
      end
    end
    agent_resources
  end

  def self.prefetch(resources)
    agent_resource = instances
    resources.keys.each do |name|
      if provider = agent_resource.find do |r|
            r.subscription == resources[name][:subscription] && r.entity == resources[name][:entity] && r.namespace == resources[name][:namespace]
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
Puppet.notice("subscrtions before #{entity['subscriptions']}")
    if add
      if ! entity.key?('subscriptions')
        entity['subscriptions'] = []
      end
      entity['subscriptions'] << resource[:subscription]
    else
      entity['subscriptions'].delete(resource[:subscription])
    end
Puppet.notice("subscription=#{resource[:subscription]}")
    Puppet.notice("subscriptions after #{entity['subscriptions']}")
    metadata = entity['metadata']
    entity.delete('metadata')
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

