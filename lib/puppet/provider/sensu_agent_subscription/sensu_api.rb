require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_agent_subscription).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_agent_subscription using sensu API"

  mk_resource_methods

  def self.instances
    agent_resources = []

    namespaces.each do |namespace|
      data = api_request('entities', nil, {:namespace => namespace})
      next if (data.nil? || data.empty?)
      data.each do |d|
        d['subscriptions'].each do |s|
          agent_resource = {}
          agent_resource[:ensure] = :present
          agent_resource[:resource] = s
          agent_resource[:entity] = d['metadata']['name']
          agent_resource[:namespace] = d['metadata']['namespace']
          agent_resource[:name] = "#{agent_resource[:subscription]} on #{agent_resource[:entity]} in #{agent_resource[:namespace]}"
          agent_resources << new(agent_resource)
        end
      end
    end
    agent_resources
  end

  def self.prefetch(resources)
    agent_resources = instances
    resources.keys.each do |name|
      if provider = agent_resources.find do |r|
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
    if add
      if ! entity.key?('subscriptions')
        entity['subscriptions'] = []
      end
      entity['subscriptions'] << resource[:subscription]
    else
      entity['subscriptions'].delete(resource[:subscription])
    end
    opts = {
      :namespace => resource[:namespace],
      :method => 'put',
    }
    api_request("entities/#{resource[:entity]}", entity, opts)
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

