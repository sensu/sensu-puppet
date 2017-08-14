
Puppet::Type.newtype(:sensu_contact) do
  @doc = "Manages Sensu contacts"

  def initialize(*args)
    super *args

    if c = catalog
      self[:notify] = [
        'Service[sensu-server]',
        'Service[sensu-enterprise]',
      ].select { |ref| c.resource(ref) }
    end
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    isnamevar
    # Valid names documented at
    # https://sensuapp.org/docs/0.29/enterprise/contact-routing.html#contact-names
    newvalues(/^[\w\.-]+$/)
    desc 'The name of the contact, e.g. "support"'
  end

  newproperty(:config) do
    desc 'Configuration hash for the contact.'

    def is_to_s(hash = @is)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def should_to_s(hash = @should[0])
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def insync?(is)
      is_to_s(is) == should_to_s
    end

    defaultto {}
  end

  newparam(:base_path) do
    desc 'The base path to the contact config file'
    defaultto '/etc/sensu/conf.d/contacts/'
  end

  autorequire(:package) do
    ['sensu']
  end
end
