Puppet::Type.newtype(:sensu_default_handler) do
  @doc = "Manages the list of default handlers.

  See https://sensuapp.org/docs/latest/getting-started-with-handlers#create-the-set-handler-definition for further details."

  # this makes me sad :( -- puppet 4 introduces #autonotify
  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-client]",
      "Service[sensu-server]",
    ].select { |ref| catalog.resource(ref) }
  end

  ensurable

  newparam(:name) do
    desc "The name of the check."
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  autorequire(:package) do
    ['sensu']
  end

  autorequire(:file) do
    [File.join(self[:base_path], 'default_handler.json')]
  end

  autorequire(:sensu_handler) do
    [self[:name]]
  end
end
