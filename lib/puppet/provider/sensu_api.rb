require 'net/http'

class Puppet::Provider::SensuAPI
  def auth_test(url, username, password)
    auth_test_url = URI.join(url, '/auth/test')
    uri = URI(auth_test_url)
    Puppet.debug("GET: #{auth_test_url}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == 'https'
    request = Net::HTTP::Get.new(uri.path)
    request.add_field("Accept", "application/json")
    request.basic_auth(username, password)
    response = http.request(request)
    if response.kind_of?(Net::HTTPSuccess)
      return true
    elsif response.kind_of?(Net::HTTPUnauthorized)
      return false
    else
      Puppet.notice "Error contacting #{auth_test_url}"
      return false
    end
  rescue Exception => e
    Puppet.notice "Unable to connect to #{auth_test_url}: #{e.message}"
    return false
  end
end
