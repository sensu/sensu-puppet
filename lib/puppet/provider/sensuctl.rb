require 'etc'
require 'json'
require 'tempfile'

class Puppet::Provider::Sensuctl < Puppet::Provider
  initvars

  commands :sensuctl_cmd => 'sensuctl'

  class << self
    attr_accessor :chunk_size
    attr_accessor :path
    attr_accessor :validate_namespaces
  end

  def validate_namespaces
    self.class.validate_namespaces
  end

  def self.config_path
    begin
      home = Dir.home
    rescue ArgumentError, NoMethodError
      # https://github.com/sensu/sensu-puppet/issues/1072
      # since $HOME is not set in systemd service File.expand_path('~') won't work
      home = Etc.getpwuid(Process.uid).dir
    end
    File.join(home, '.config/sensu/sensuctl/cluster')
  end
  def config_path
    self.class.config_path
  end

  def self.sensuctl_config(path = nil)
    path ||= config_path
    return {} unless File.file?(path)
    file = File.read(path)
    config = JSON.parse(file)
    Puppet.debug("CONFIG: #{config}")
    config
  end
  def sensuctl_config(*args)
    self.class.sensuctl_config(*args)
  end

  def self.type_properties
    resource_type.validproperties.reject { |p| p.to_sym == :ensure }
  end
  def type_properties
    self.class.type_properties
  end

  def self.convert_boolean_property_value(value)
    case value
    when :true
      true
    when :false
      false
    else
      value
    end
  end
  def convert_boolean_property_value(value)
    self.class.convert_boolean_property_value(value)
  end

  def self.sensuctl(args)
    sensuctl_cmd = which('sensuctl')
    if ! path.nil?
      cmd = [path] + args
    else
      cmd = [sensuctl_cmd] + args
    end
    execute(cmd)
  end
  def sensuctl(*args)
    self.class.sensuctl(*args)
  end

  def self.sensuctl_list(command, namespaces = true)
    args = [command]
    args << 'list'
    if namespaces
      args << '--all-namespaces'
    end
    args << '--format'
    args << 'json'
    if ! chunk_size.nil?
      args << '--chunk-size'
      args << chunk_size.to_s
    end
    data = []
    output = sensuctl(args)
    Puppet.debug("sensuctl #{args.join(' ')}: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug("Unable to parse output from sensuctl #{args.join(' ')}")
      return []
    end
    return [] if data.nil?
    data
  end

  def self.resource_file(type, metadata, spec, api_version = 'core/v2')
    data = {}
    data['type'] = type
    data['api_version'] = api_version
    data['metadata'] = metadata
    data['spec'] = spec
    f = Tempfile.new('sensuctl')
    f.write(JSON.pretty_generate(data))
    f.close
    Puppet.debug(IO.read(f.path))
    f
  end

  def self.sensuctl_create(type, metadata, spec, api_version = 'core/v2')
    f = resource_file(type, metadata, spec, api_version)
    sensuctl(['create', '--file', f.path])
  end
  def sensuctl_create(*args)
    self.class.sensuctl_create(*args)
  end

  def self.sensuctl_delete(command, name, namespace = nil, metadata = nil, spec = nil, api_version = 'core/v2')
    f = nil
    if spec && metadata
      f = resource_file(command, metadata, spec, api_version)
      args = ['delete','--file',f.path]
    else
      args = [command]
      args << 'delete'
      args << name
      args << '--skip-confirm'
      if namespace
        args << '--namespace'
        args << namespace
      end
    end
    sensuctl(args)
  end
  def sensuctl_delete(*args)
    self.class.sensuctl_delete(*args)
  end

  def self.sensuctl_auth_types()
    output = sensuctl(['auth','list','--format','yaml'])
    Puppet.debug("YAML auth list: #{output}")
    auth_types = {}
    auths = output.split('---')
    Puppet.debug("auths: #{auths}")
    auths.each do |auth|
      a = YAML.load(auth)
      auth_types[a['metadata']['name']] = a['type']
    end
    Puppet.debug("auth_types: #{auth_types}")
    auth_types
  end

  def self.dump(resource_type)
    # Dump YAML because 'sensuctl dump' does not yet support '--format json'
    # https://github.com/sensu/sensu-go/issues/3424
    output = sensuctl(['dump',resource_type,'--format','yaml','--all-namespaces'])
    Puppet.debug("YAML dump of #{resource_type}:\n#{output}")
    resources = []
    dumps = output.split('---')
    dumps.each do |d|
      resources << YAML.load(d)
    end
    resources
  end
  def dump(*args)
    self.class.dump(*args)
  end

  def self.namespaces()
    begin
      data = self.sensuctl_list('namespace', false)
      namespaces = []
      data.each do |d|
        namespaces << d['name']
      end
    rescue Exception
      return []
    end
    namespaces
  end
  def namespaces()
    self.class.namespaces()
  end

  def self.config
    output = sensuctl(['config','view'])
    data = JSON.parse(output)
    return data
  rescue Exception => e
    Puppet.info("Error executing 'sensuctl config view': #{e}")
    return {}
  end

  def self.valid_json?(json)
    return false if json.nil?
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end
  def valid_json?(json)
    self.class.valid_json?(json)
  end
end
