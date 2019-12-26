require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_cluster_member).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_cluster_member using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    cluster_members = []

    output = sensuctl(['cluster', 'member-list', '--format', 'json'])
    Puppet.debug("sensu cluster members: #{output}")
    begin
      j = output.split(/\n\n/)
      if j.size >= 2
        _json = j[1]
      else
        _json = j[0]
      end
      data = JSON.parse(_json)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl cluster member-list')
      data = {'members' => []}
    end

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
    begin
      output = sensuctl(['cluster', 'member-add', resource[:name], peer_urls])
      output.each_line do |line|
        Puppet.info("Cluster member-add #{resource[:name]}: #{line}")
      end
    rescue Exception => e
      raise Puppet::Error, "sensuctl cluster member-add #{resource[:name]} #{peer_urls} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if @property_flush[:peer_urls]
      peer_urls = @property_flush[:peer_urls].join(',')
      begin
        output = sensuctl(['cluster', 'member-update', @property_hash[:id], peer_urls])
        output.each_line do |line|
          Puppet.info("Cluster member-update #{resource[:name]}: #{line}")
        end
      rescue Exception => e
        raise Puppet::Error, "sensuctl cluster member-update #{resource[:name]} #{peer_urls} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl(['cluster', 'member-remove', @property_hash[:id]])
    rescue Exception => e
      raise Puppet::Error, "sensuctl cluster member-remove #{@property_hash[:id]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

