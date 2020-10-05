require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../..', 'puppet_x/sensu/agent_entity_config'))
require 'yaml'

Puppet::Type.type(:sensu_agent_entity_config).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_agent_entity_config using sensu API"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  class << self
    attr_accessor :url
    attr_accessor :username
    attr_accessor :password
  end

  def self.api_opts
    if (@url.nil? || @password.nil?) && File.exist?('/etc/sensu/agent.yml')
      agent_yaml = YAML.load(File.read('/etc/sensu/agent.yml'))
      backend = agent_yaml['backend-url'][0]
      if backend =~ /^wss:/
        proto = 'https://'
      else
        proto = 'http://'
      end
      backend.gsub!(%r{^(wss|ws)://}, '')
      backend_host = backend.split(':')[0]
      @url = "#{proto}#{backend_host}:8080" if @url.nil?
      @password = agent_yaml['password'] if @password.nil?
    end
    if @username.nil?
      @username = 'puppet-agent_entity_config'
    end
    {
      :url      => @url,
      :username => @username,
      :password => @password,
    }
  end
  def api_opts
    self.class.api_opts
  end

  def self.instances
    configs = []

    namespaces(api_opts).each do |namespace|
      data = api_request('entities', nil, api_opts.merge({:namespace => namespace}))
      next if (data.nil? || data.empty?)
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
    config = resource[:config]
    config_class = PuppetX::Sensu::AgentEntityConfig.config_classes[config]
    case config_class
    when Hash
      value = add ? resource[:value] : nil
      obj = {resource[:key] => value}
    else
      data = get_entity(resource[:entity], resource[:namespace], api_opts)
      obj = data[config]
      case config_class
      when Array
        obj = [] if add && obj.nil?
        if add
          obj << resource[:value]
        else
          obj.delete(resource[:value])
        end
      else
        obj = add ? resource[:value] : ""
      end
    end
    if version_cmp('6.1.0')
      method = 'patch'
      entity = {}
      if PuppetX::Sensu::AgentEntityConfig.metadata_configs.include?(config)
        entity['metadata'] = {}
        entity['metadata'][config] = obj
      else
        entity[config] = obj
      end
    else
      method = 'put'
      entity = get_entity(resource[:entity], resource[:namespace], api_opts)
      if PuppetX::Sensu::AgentEntityConfig.metadata_configs.include?(config)
        entity['metadata'][config] = {} if entity['metadata'][config].nil?
        entity['metadata'][config][obj.keys[0]] = obj.values[0]
      else
        entity[config] = obj
      end
    end
    opts = {
      :namespace => resource[:namespace],
      :method => method,
    }
    api_request("entities/#{resource[:entity]}", entity, api_opts.merge(opts))
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

