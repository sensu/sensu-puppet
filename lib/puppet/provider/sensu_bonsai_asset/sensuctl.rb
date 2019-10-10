require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_bonsai_asset).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_bonsai_asset using sensuctl"

  mk_resource_methods

  def self.instances
    assets = []

    data = sensuctl_list('asset')
    found_assets = []

    data.each do |d|
      asset = {}
      asset[:ensure] = :present
      asset[:bonsai_namespace] = d['metadata'].dig('annotations', 'io.sensu.bonsai.namespace')
      asset[:bonsai_name] = d['metadata'].dig('annotations', 'io.sensu.bonsai.name')
      asset[:version] = d['metadata'].dig('annotations', 'io.sensu.bonsai.version')
      if asset[:bonsai_namespace].nil? || asset[:bonsai_name].nil?
        Puppet.debug("Asset #{d['metadata']['name']} from bonsai.sensu.io lacks bonsai annotations")
        next
      end
      asset[:rename] = d['metadata']['name']
      if found_assets.include?(asset[:rename])
        next
      end
      found_assets << asset[:rename]
      asset[:namespace] = d['metadata']['namespace']
      asset[:name] = "#{asset[:bonsai_namespace]}/#{asset[:bonsai_name]} in #{asset[:namespace]}"
      assets << new(asset)
    end
    assets
  end

  def self.prefetch(resources)
    assets = instances
    resources.keys.each do |name|
      if provider = assets.find { |c| c.rename == resources[name][:rename] && c.namespace == resources[name][:namespace] }
        resources[name].provider = provider
      end
    end
  end

  def self.latest_version(namespace, name)
    return @latest_version if @latest_version
    @latest_version = nil
    return nil if namespace.nil? || name.nil?
    versions = []
    bonsai_asset = self.get_bonsai_asset("#{namespace}/#{name}")
    (bonsai_asset['versions'] || []).each do |bonsai_version|
      version = bonsai_version['version']
      next unless version =~ /^[0-9]/
      versions << version
    end
    versions = versions.sort_by { |v| Gem::Version.new(v) }
    @latest_version = versions.last
    @latest_version
  end

  def self.get_bonsai_asset(name)
    data = {}
    url = "https://bonsai.sensu.io/api/v1/assets/#{name}"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.path)
    request.add_field("Accept", "application/json")
    Puppet.debug("GET: #{url}")
    response = http.request(request)
    if valid_json?(response.body)
      data = JSON.parse(response.body)
      Puppet.debug("BODY: #{JSON.pretty_generate(data)}")
    else
      Puppet.debug("BODY: Not valid JSON")
    end
    unless response.kind_of?(Net::HTTPSuccess)
      Puppet.notice "Unable to connect to bonsai at #{url}"
      return {}
    end
  rescue Exception => e
    Puppet.notice "Unable to connect to bonsai at #{url}: #{e.message}"
    return {}
  else
    return data
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

  def asset_add(version)
    cmd = ['asset', 'add']
    name = "#{resource[:bonsai_namespace]}/#{resource[:bonsai_name]}"
    if version && version.to_s != 'latest'
      name = "#{name}:#{version}"
    end
    cmd << name
    cmd << '--rename'
    cmd << resource[:rename]
    cmd << '--namespace'
    cmd << resource[:namespace]
    begin
      sensuctl(cmd)
    rescue Exception => e
      raise Puppet::Error, "#{cmd.join(' ')} failed\nError message: #{e.message}"
    end
  end

  def create
    asset_add(resource[:version])
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      asset_add(@property_flush[:version])
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('asset', resource[:rename], resource[:namespace])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete asset #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

