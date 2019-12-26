require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_cluster_member).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_cluster_member using sensu API"

  mk_resource_methods

  def self.instances
    cluster_members = []

    data = api_request('cluster/members')
    data['members'].each do |d|
      cluster_member = {}
      cluster_member[:ensure] = :present
      cluster_member[:name] = d['name']
      # Skip member if no name, occurs if new member not yet started
      next if cluster_member[:name].nil?
      if d['ID'].is_a? Integer
        cluster_member[:id] = d['ID'].to_s(16)
      else
        cluster_member[:id] = d['ID']
      end
      cluster_member[:peer_urls] = d['peerURLs']
      cluster_members << new(cluster_member)
    end
    cluster_members
  end

  def self.prefetch(resources)
    cluster_members = instances
    resources.keys.each do |name|
      if provider = cluster_members.find { |e| e.name == name }
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

  def create
    peer_urls = resource[:peer_urls].join(',')
    api_request('cluster/members', {'peer-addrs' => peer_urls}, {:method => 'post-form'})
    @property_hash[:ensure] = :present
  end

  def flush
    if @property_flush[:peer_urls]
      peer_urls = @property_flush[:peer_urls].join(',')
      api_request("cluster/members/#{@property_hash[:id]}", {'peer-addrs' => peer_urls}, {:method => 'put-form'})
    end
    @property_hash = resource.to_hash
  end

  def destroy
    api_request("cluster/members/#{@property_hash[:id]}", nil, {:method => 'delete'})
    @property_hash.clear
  end
end

