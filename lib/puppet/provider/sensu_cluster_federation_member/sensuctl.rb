require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_cluster_federation_member).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_cluster_federation_member using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    members = []

    data = dump('federation/v1.Cluster')
    data.each do |d|
      cluster = d['metadata']['name']
      d['spec']['api_urls'].each do |api_url|
        member = {}
        member[:ensure] = :present
        member[:name] = "#{api_url} in #{cluster}"
        member[:api_url] = api_url
        member[:cluster] = cluster
        members << new(member)
      end
    end
    members
  end

  def self.prefetch(resources)
    members = instances
    resources.keys.each do |name|
      if provider = members.find { |c| c.api_url == resources[name][:api_url] && c.cluster == resources[name][:cluster] }
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

  def api_urls
    data = dump('federation/v1.Cluster')
    return [] if data.empty?
    data.each do |d|
      if d['metadata']['name'] == resource[:cluster]
        return d['spec']['api_urls']
      end
    end
    return []
  end

  def update(urls)
    spec = {}
    spec[:api_urls] = urls
    metadata = {}
    metadata[:name] = resource[:cluster]
    begin
      sensuctl_create('Cluster', metadata, spec, 'federation/v1')
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
  end

  def create
    urls = api_urls
    urls << resource[:api_url]
    update(urls)
    @property_hash[:ensure] = :present
  end

  def destroy
    urls = api_urls
    urls.delete(resource[:api_url])
    update(urls)
    @property_hash.clear
  end
end
