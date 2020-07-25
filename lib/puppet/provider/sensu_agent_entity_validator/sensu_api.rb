require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_agent_entity_validator).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "A provider for the resource type `sensu_agent_entity_validator`"

  defaultfor :kernel => ['Linux','windows']

  def validate
    opts = {
      :namespace  => resource[:namespace],
      :failonfail => false,
    }
    data = api_request("entities/#{resource[:name]}", nil, opts)
    !data.empty?
  end

  # Test to see if the resource exists, returns true if it does, false if it
  # does not.
  #
  # Here we simply monopolize the resource API, to execute a test to see if the
  # entity exists. When we return a state of `false` it triggers the
  # create method where we can return an error message.
  #
  # @return [bool] did the test succeed?
  def exists?
    start_time = Time.now
    timeout = resource[:timeout]

    success = validate

    while success == false && ((Time.now - start_time) < timeout)
      # It can take several seconds for the sensu_api server to start up;
      # especially on the first install.  Therefore, our first connection attempt
      # may fail.  Here we have somewhat arbitrarily chosen to retry every 2
      # seconds until the configurable timeout has expired.
      Puppet.notice("Failed to connect to validate entity #{resource[:name]}; sleeping 2 seconds before retry")
      sleep 2
      success = validate
    end

    unless success
      Puppet.notice("Failed to connect validate entity #{resource[:name]} within timeout window of #{timeout} seconds; giving up.")
    end

    success
  end

  # This method is called when the exists? method returns false.
  #
  # @return [void]
  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the connection could not be established... so we need to
    # cause a failure here.
    raise Puppet::Error, "Unable to connect to validate entity #{resource[:name]} in namespace #{resource[:namespace]}"
  end
end

