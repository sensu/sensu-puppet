# See: #10295 for more details.
#
# This is a workaround for bug: #4248 whereby ruby files outside of the normal
# provider/type path do not load until pluginsync has occured on the puppetmaster
#
# In this case I'm trying the relative path first, then falling back to normal
# mechanisms. This should be fixed in future versions of puppet but it looks
# like we'll need to maintain this for some time perhaps.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/util/sensu_api_validator'

# This file contains a provider for the resource type `sensu_api_validator`,
# which validates the sensu_api connection by attempting an https connection.

Puppet::Type.type(:sensu_api_validator).provide(:puppet_https) do
  desc "A provider for the resource type `sensu_api_validator`,
        which validates the sensu_api connection by attempting an http(s)
        connection to the sensu_api server.  Uses the puppet SSL certificate
        setup from the local puppet environment to authenticate if use_ssl
        is set to true."

  # Test to see if the resource exists, returns true if it does, false if it
  # does not.
  #
  # Here we simply monopolize the resource API, to execute a test to see if the
  # database is connectable. When we return a state of `false` it triggers the
  # create method where we can return an error message.
  #
  # @return [bool] did the test succeed?
  def exists?
    start_time = Time.now
    timeout = resource[:timeout]

    success = validator.attempt_connection

    while success == false && ((Time.now - start_time) < timeout)
      # It can take several seconds for the sensu_api server to start up;
      # especially on the first install.  Therefore, our first connection attempt
      # may fail.  Here we have somewhat arbitrarily chosen to retry every 2
      # seconds until the configurable timeout has expired.
      Puppet.notice("Failed to connect to sensu_api; sleeping 2 seconds before retry")
      sleep 2
      success = validator.attempt_connection
    end

    unless success
      Puppet.notice("Failed to connect to sensu_api within timeout window of #{timeout} seconds; giving up.")
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
    raise Puppet::Error, "Unable to connect to sensu_api server! (#{@validator.sensu_api_server}:#{@validator.sensu_api_port})"
  end

  # Returns the existing validator, if one exists otherwise creates a new object
  # from the class.
  #
  # @api private
  def validator
    @validator ||= Puppet::Util::SensuAPIValidator.new(resource[:sensu_api_server], resource[:sensu_api_port], resource[:use_ssl], resource[:test_url])
  end

end

