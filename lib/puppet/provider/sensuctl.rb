require 'etc'
require 'json'
require 'tempfile'

class Puppet::Provider::Sensuctl < Puppet::Provider
  initvars

  commands :sensuctl => 'sensuctl'

  def config_path
    user_name = Etc.getpwuid(Process.uid).name
    home = Etc.getpwnam(user_name).dir
    File.join(home, '.config/sensu/sensuctl/cluster')
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

  def self.sensuctl_list(command)
    args = [command]
    args << 'list'
    if ! ['cluster-role','cluster-role-binding','namespace','user'].include?(command)
      args << '--all-namespaces'
    end
    args << '--format'
    args << 'json'
    sensuctl(args)
  end

  def self.sensuctl_create(type, metadata, spec)
    data = {}
    if type =~ /^[A-Z]/
      data['type'] = type
    else
      data['type'] = type.capitalize
    end
    data['api_version'] = 'core/v2'
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

  def self.sensuctl_delete(command, name)
    args = [command]
    args << 'delete'
    args << name
    args << '--skip-confirm'
    sensuctl(args)
  end
  def sensuctl_delete(*args)
    self.class.sensuctl_delete(*args)
  end

  def self.sensuctl_set(command, name, property, value: nil, flags:  nil)
    args = [command]
    args << "set-" + property.gsub('_', '-')
    args << name
    args << value unless value.nil?
    args += flags unless flags.nil?
    sensuctl(args)
  end
  def sensuctl_set(*args)
    self.class.sensuctl_set(*args)
  end

  def self.sensuctl_remove(command, name, property)
    args = [command]
    args << "remove-" + property.gsub('_', '-')
    args << name
    sensuctl(args)
  end
  def sensuctl_remove(*args)
    self.class.sensuctl_remove(*args)
  end
end

