require 'json'

class Puppet::Provider::Sensuctl < Puppet::Provider
  initvars

  commands :sensuctl => 'sensuctl'

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

  #def self.sensuctl(args)
  #  execute(['sensuctl'] + args, combine: false, failonfail: true)
  #end

  def self.sensuctl_list(command)
    args = [command]
    args << 'list'
    args << '--all-organizations'
    args << '--format'
    args << 'json'
    sensuctl(args)
  end

  def self.sensuctl_create(type, spec)
    data = {}
    data['type'] = type.capitalize
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

