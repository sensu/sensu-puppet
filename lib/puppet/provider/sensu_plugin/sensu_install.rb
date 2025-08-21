Puppet::Type.type(:sensu_asset).provide(:sensuctl) do
  desc "Provider for Sensu Go assets using sensuctl"

  mk_resource_methods

  commands :sensuctl => 'sensuctl'

  def self.instances
    assets = []

    begin
      output = sensuctl('asset', 'list', '--format', 'json')
      Puppet.debug("sensuctl asset list output: #{output}")
      
      if output && !output.strip.empty?
        require 'json'
        asset_list = JSON.parse(output)
        
        asset_list.each do |asset_data|
          next unless asset_data['metadata'] && asset_data['metadata']['name']
          
          asset = {
            :name      => asset_data['metadata']['name'],
            :ensure    => :present,
            :url       => extract_url_from_asset(asset_data),
            :sha512    => extract_sha512_from_asset(asset_data),
            :namespace => asset_data['metadata']['namespace'] || 'default',
          }
          Puppet.debug("asset: #{asset}")
          assets << new(asset)
        end
      end
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Failed to list assets: #{e.message}")
      # Return empty array if sensuctl fails (e.g., not configured)
    rescue JSON::ParserError => e
      Puppet.debug("Failed to parse asset list JSON: #{e.message}")
    end
    
    assets
  end

  def self.prefetch(resources)
    assets = instances
    resources.keys.each do |name|
      if provider = assets.find { |a| a.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.extract_url_from_asset(asset_data)
    return nil unless asset_data['spec'] && asset_data['spec']['builds']
    
    # Get first build's URL as representative
    first_build = asset_data['spec']['builds'][0]
    first_build ? first_build['url'] : nil
  end

  def self.extract_sha512_from_asset(asset_data)
    return nil unless asset_data['spec'] && asset_data['spec']['builds']
    
    # Get first build's SHA512 as representative
    first_build = asset_data['spec']['builds'][0]
    first_build ? first_build['sha512'] : nil
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def url=(value)
    @property_flush[:url] = value
  end

  def sha512=(value)
    @property_flush[:sha512] = value
  end

  def namespace=(value)
    @property_flush[:namespace] = value
  end

  def add_asset_from_bonsai
    args = ['asset', 'add']
    
    # Handle namespaced resources and version specification
    if resource[:version] && resource[:version] != :latest
      asset_name = "#{resource[:name]}:#{resource[:version]}"
    else
      asset_name = resource[:name]
    end
    args << asset_name

    # Add rename option if specified
    if resource[:rename]
      args << '-r'
      args << resource[:rename]
    end

    # Add namespace if not default
    if resource[:namespace] && resource[:namespace] != 'default'
      args << '--namespace'
      args << resource[:namespace]
    end

    Puppet.debug("Running: sensuctl #{args.join(' ')}")
    sensuctl(args)
  end

  def add_asset_from_url
    require 'json'
    
    # Create asset definition for custom URL
    asset_definition = {
      'type' => 'Asset',
      'api_version' => 'core/v2',
      'metadata' => {
        'name' => resource[:name],
        'namespace' => resource[:namespace] || 'default'
      },
      'spec' => {
        'builds' => [
          {
            'url' => resource[:url],
            'sha512' => resource[:sha512],
            'filters' => resource[:filters] || [
              "entity.system.os == 'linux'",
              "entity.system.arch == 'amd64'"
            ]
          }
        ]
      }
    }

    # Write asset definition to temporary file and create via sensuctl
    require 'tempfile'
    Tempfile.open(['sensu_asset', '.json']) do |f|
      f.write(JSON.pretty_generate(asset_definition))
      f.flush
      sensuctl('create', '-f', f.path)
    end
  end

  def create
    begin
      if resource[:url]
        # Custom asset from URL
        add_asset_from_url
      else
        # Asset from Bonsai
        add_asset_from_bonsai
      end
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "sensuctl asset add of #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      # For asset updates, we need to delete and recreate
      begin
        destroy
        create
      rescue Exception => e
        raise Puppet::Error, "sensuctl asset update of #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    args = ['asset', 'delete', resource[:name]]
    
    # Add namespace if not default
    if resource[:namespace] && resource[:namespace] != 'default'
      args << '--namespace'
      args << resource[:namespace]
    end

    # Skip interactive confirmation
    args << '--skip-confirm'

    begin
      sensuctl(args)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "sensuctl asset delete of #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end

  def self.check_outdated_assets
    begin
      output = sensuctl('asset', 'outdated')
      Puppet.debug("Outdated assets: #{output}")
      return output
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Failed to check outdated assets: #{e.message}")
      return nil
    end
  end
end