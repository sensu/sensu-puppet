require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_bonsai_asset).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_bonsai_asset using sensu API"

  mk_resource_methods

  def self.instances
    assets = []
    found_assets = []

    namespaces.each do |namespace|
      data = api_request('assets', nil, {:namespace => namespace})
      next if (data.nil? || data.empty?)
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
    get_bonsai_latest_version(namespace, name)
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

  def manage_asset(version, exists)
    name = "#{resource[:bonsai_namespace]}/#{resource[:bonsai_name]}"
    if exists
      method = 'put'
      url = "assets/#{URI.escape(name, '/')}"
    else
      method = 'post'
      url = "assets"
    end
    if version && version.to_s != 'latest'
      version_match = version
    else
      version_match = self.class.latest_version(resource[:bonsai_namespace], resource[:bonsai_name])
    end
    bonsai_asset_data = get_bonsai_asset(name)
    if bonsai_asset_data.nil? || bonsai_asset_data.empty?
      raise Puppet::Error, "Unable to locate Bonsai asset #{name}"
    end
    bonsai_asset = bonsai_asset_data['versions'].find { |a| a['version'] == version_match }
    if bonsai_asset.nil?
      raise Puppet::Error, "Sensu_bonsai_asset[#{resource[:name]}] Unable to locate Bonsai asset #{name} version #{version_match}"
    end
    builds = []
    bonsai_asset['assets'].each do |a|
      build = {
        :url => a['asset_url'],
        :sha512 => a['asset_sha'],
        :filters => a['filter'],
      }
      builds << build
    end
    asset = {
      :metadata => {
        'name' => resource[:rename],
        'namespace' => resource[:namespace],
        'annotations' => bonsai_asset['assets'][0]['annotations'],
      },
      :builds => builds,
    }
    opt = {
      :method => method,
      :namespace => resource[:namespace],
    }
    api_request(url, asset, opt)
  end

  def create
    manage_asset(resource[:version], false)
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      manage_asset(@property_flush[:version], true)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :namespace => resource[:namespace],
      :method => 'delete',
    }
    api_request("assets/#{URI.escape(resource[:rename], '/')}", nil, opts)
    @property_hash.clear
  end
end

