require 'net/http'

module Puppet
  module Util
    # Validator class, for testing that SensuAPI is alive
    class SensuAPIValidator
      attr_reader :sensu_api_server
      attr_reader :sensu_api_port
      attr_reader :use_ssl
      attr_reader :test_path
      attr_reader :test_headers

      def initialize(sensu_api_server, sensu_api_port, use_ssl=false, test_path = "/version")
        @sensu_api_server = sensu_api_server
        @sensu_api_port   = sensu_api_port
        @use_ssl         = use_ssl
        @test_path       = test_path
      end

      # Utility method; attempts to make an http/https connection to the sensu_api server.
      # This is abstracted out into a method so that it can be called multiple times
      # for retry attempts.
      #
      # @return true if the connection is successful, false otherwise.
      def attempt_connection
        # All that we care about is that we are able to connect successfully via
        # http(s), so here we're simpling hitting a somewhat arbitrary low-impact URL
        # on the sensu_api server.
        http = Net::HTTP.new(@sensu_api_server, @sensu_api_port)
        http.use_ssl = @use_ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(@test_path)
        request.add_field("Accept", "application/json")
        response = http.request(request)

        unless response.kind_of?(Net::HTTPSuccess) || response.kind_of?(Net::HTTPUnauthorized)
          Puppet.notice "Unable to connect to sensu_api server (http#{use_ssl ? "s" : ""}://#{sensu_api_server}:#{sensu_api_port}): [#{response.code}] #{response.msg}"
          return false
        end
        return true
      rescue Exception => e
        Puppet.notice "Unable to connect to sensu_api server (http#{use_ssl ? "s" : ""}://#{sensu_api_server}:#{sensu_api_port}): #{e.message}"
        return false
      end
    end
  end
end

