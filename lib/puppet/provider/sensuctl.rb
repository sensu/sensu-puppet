require 'etc'
require 'json'
require 'tempfile'

class Puppet::Provider::Sensuctl < Puppet::Provider
  initvars

  commands :sensuctl => 'sensuctl'

  class << self
    attr_accessor :chunk_size
  end

  def self.config_path
    # https://github.com/sensu/sensu-puppet/issues/1072
    # since $HOME is not set in systemd service File.expand_path('~') won't work
    home = Etc.getpwuid(Process.uid).dir
    File.join(home, '.config/sensu/sensuctl/cluster')
  end
  def config_path
    self.class.config_path
  end

  def load_config(path)
    return {} unless File.file?(path)
    file = File.read(path)
    config = JSON.parse(file)
    Puppet.debug("CONFIG: #{config}")
    config
  end

  def self.type_properties
    resource_type.validproperties.reject { |p| p.to_sym == :ensure }
  end
  def type_properties
    self.class.type_properties
  end

  def convert_boolean_property_value(value)
    case value
    when :true
      true
    when :false
      false
    else
      value
    end
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

  def self.sensuctl_create(type, metadata, spec, api_version = 'core/v2')
    data = {}
    data['type'] = type
    data['api_version'] = api_version
    data['metadata'] = metadata
    data['spec'] = spec
    f = Tempfile.new('sensuctl')
    f.write(JSON.pretty_generate(data))
    f.close
    Puppet.debug(IO.read(f.path))
    sensuctl(['create', '--file', f.path])
  end
  def sensuctl_create(*args)
    self.class.sensuctl_create(*args)
  end

  def self.sensuctl_delete(command, name, namespace = nil)
    args = [command]
    args << 'delete'
    args << name
    args << '--skip-confirm'
    if namespace
      args << '--namespace'
      args << namespace
    end
    sensuctl(args)
  end
  def sensuctl_delete(*args)
    self.class.sensuctl_delete(*args)
  end

  def self.sensuctl_info(command, name, namespace = nil)
    args = [command]
    args << 'info'
    args << name
    args << '--format'
    args << 'json'
    if namespace
      args << '--namespace'
      args << namespace
    end
    output = sensuctl(args)
    Puppet.debug("sensuctl #{args.join(' ')}: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug("Unable to parse output from sensuctl #{args.join(' ')}")
      return {}
    end
    return {} if data.nil?
    data
  end
  def sensuctl_info(*args)
    self.class.sensuctl_info(*args)
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
end

