require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_cluster_federation_member).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_cluster_federation_member using sensu API"

  mk_resource_methods

  def self.instances
    members = []

    opts = {
      :api_group => 'enterprise/federation',
      :api_version => 'v1',
    }
    data = api_request('clusters', nil, opts)
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
    opts = {
      :api_group => 'enterprise/federation',
      :api_version => 'v1',
      :failonfail => false,
    }
    data = api_request("clusters/#{resource[:cluster]}", nil, opts)
    return [] if data.empty?
    data['spec']['api_urls']
  end

  def request(urls)
    spec = {}
    metadata = {}
    metadata[:name] = resource[:cluster]
    spec[:api_urls] = urls
    data = {}
    data[:spec] = spec
    data[:metadata] = metadata
    data[:api_version] = 'federation/v1'
    data[:type] = 'Cluster'
    opts = {
      :api_group => 'enterprise/federation',
      :api_version => 'v1',
      :method => 'put',
    }
    api_request("clusters/#{resource[:cluster]}", data, opts)
  end

  def create
    urls = api_urls
    urls << resource[:api_url]
    request(urls)
    @property_hash[:ensure] = :present
  end

  def destroy
    urls = api_urls
    urls.delete(resource[:api_url])
    request(urls)
    @property_hash.clear
  end
end
