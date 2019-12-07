require File.expand_path(File.join(File.dirname(__FILE__), 'sensuctl'))
require 'json'
require 'net/http'

class Puppet::Provider::SensuAPI < Puppet::Provider
  initvars

  class << self
    attr_accessor :url
    attr_accessor :username
    attr_accessor :password
    attr_accessor :old_password
    attr_accessor :access_token
    attr_accessor :refresh_token
  end

  def self.update_access_token
    auth_success = self.auth(@username, @password)
    return if auth_success
    auth_old_success = self.auth(@username, @old_password)
    return if auth_old_success
    auth_token_success = self.auth_token()
    return if auth_token_success
  end
  def update_access_token
    self.class.update_access_token
  end

  def self.type_properties
    resource_type.validproperties.reject { |p| p.to_sym == :ensure }
  end
  def type_properties
    self.class.type_properties
  end

  def convert_boolean_property_value(value)
    Puppet::Provider::Sensuctl.convert_boolean_property_value(value)
  end

  def self.namespaces
    opts = {
      :namespace => nil,
    }
    Puppet.debug("Fetching namespaces via Sensu API")
    data = api_request('namespaces')
    names = []
    data.each do |d|
      names << d['name']
    end
    names
  rescue Exception => e
    Puppet.debug("ERROR fetching namespaces via Sensu API: #{e.backtrace.join("\n")}")
    return []
  end
  def namespaces
    self.class.namespaces
  end

  def self.api_request(path, data = nil, opts = {})
    api_group = opts[:api_group] || 'core'
    api_version = opts[:api_version] || 'v2'
    namespace = opts[:namespace] || nil
    url = opts[:url] || @url
    username = opts[:username] || @username
    password = opts[:password] || @password
    method = opts[:method] || 'get'
    failonfail = opts[:failonfail].nil? ? true : opts[:failonfail]
    if opts[:use_token] == false
      token = nil
    else
      token = @access_token
    end
    if path =~ %r{^/}
      uri = URI(URI.join(url, path))
    elsif namespace
      uri = URI(URI.join(url, "/api/#{api_group}/#{api_version}/namespaces/#{namespace}/#{path}"))
    else
      uri = URI(URI.join(url, "/api/#{api_group}/#{api_version}/#{path}"))
    end
    if method == 'get' && !data.nil?
      uri.query = URI.encode_www_form(data)
    end
    Puppet.debug("method=#{method}: #{uri.to_s}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    if method == 'get'
      request = Net::HTTP::Get.new(uri.path)
    elsif method == 'post'
      request = Net::HTTP::Post.new(uri.path)
    elsif method == 'put'
      request = Net::HTTP::Put.new(uri.path)
    elsif method == 'delete'
      request = Net::HTTP::Delete.new(uri.path)
    end
    # Add data for POST and PUT
    if ['post','put'].include?(method)
      Puppet.debug("BODY: #{data.to_json}")
      request.body = data.to_json unless data.nil?
    end
    # Add headers
    request.add_field("Accept", "application/json") if defined?(request) && !request.nil?
    request.add_field("Content-Type", "application/json") if defined?(request) && !request.nil?
    # Add either token or basic auth
    if token.nil? && username && password
      Puppet.debug("Sensu API: Using basic auth of #{username}:#{password}")
      request.basic_auth(username, password) if defined?(request) && !request.nil?
    else
      Puppet.debug("Sensu API: Using token #{token}")
      request.add_field("Authorization", "Bearer #{token}") if defined?(request) && !request.nil?
    end
    # Make request
    if method == 'post-form' || method == 'put-form'
      encoded_form = URI.encode_www_form(data)
      headers = { content_type: "application/x-www-form-urlencoded", authorization: "Bearer #{token}" }
    end
    if method == 'post-form'
      response = http.request_post(uri.path, encoded_form, headers)
    elsif method == 'put-form'
      response = http.request_put(uri.path, encoded_form, headers)
    else
      response = http.request(request)
    end
    Puppet.debug("RESPONSE: #{response.code}\n#{response.body}")
    return response if opts[:return_response]
    # Handle expired auth token and retry
    if response.kind_of?(Net::HTTPUnauthorized) && opts[:retry] != false
      update_access_token
      opts[:retry] = false
      return api_request(path, data, opts)
    end
    unless response.kind_of?(Net::HTTPSuccess)
      raise Puppet::Error, "Unable to make API request at #{uri.to_s}: #{response.class}"
    end
    if Puppet::Provider::Sensuctl.valid_json?(response.body)
      data = JSON.parse(response.body)
      Puppet.debug("BODY: #{JSON.pretty_generate(data)}")
      return data
    else
      Puppet.debug("BODY: Not valid JSON")
      return {}
    end
  rescue Puppet::Error => e
    if failonfail
      raise
    else
      Puppet.notice "Unable to connect to #{uri.to_s}: #{e.message}"
      return {}
    end
  end
  def api_request(*args)
    self.class.api_request(*args)
  end

  def self.auth(username, password)
    opts = {
      username: username,
      password: password,
      use_token: false,
      return_response: true,
    }
    response = api_request('/auth', nil, opts)
    if response.kind_of?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      @access_token = data['access_token']
      @refresh_token = data['refresh_token']
      return true
    else
      return false
    end
  end

  def self.auth_token(username = nil, password = nil)
    opts = {
      username: username,
      password: password,
      return_response: true,
      method: 'post',
    }
    response = api_request('/auth/token', {'refresh_token': @refresh_token}, opts)
    if response.kind_of?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      @access_token = data['access_token']
      @refresh_token = data['refresh_token']
      return true
    else
      return false
    end
  end

  def self.auth_test(url = nil, username, password)
    opts = {
      url: url,
      username: username,
      password: password,
      return_response: true,
      use_token: false
    }
    response = api_request('/auth/test', nil, opts)
    if response.kind_of?(Net::HTTPSuccess)
      return true
    elsif response.kind_of?(Net::HTTPUnauthorized)
      return false
    else
      Puppet.debug "Error testing username/password using SensuAPI"
      return false
    end
  end
  def auth_test(*args)
    self.class.auth_test(*args)
  end

  def self.get_bonsai_asset(name)
    opts = {
      :url => 'https://bonsai.sensu.io'
    }
    data = api_request("/api/v1/assets/#{name}", nil, opts)
  rescue Exception => e
    Puppet.notice "Unable to connect to bonsai at #{url}: #{e.message}"
    Puppet.debug("ERROR: #{e.backtrace.join("\n")}")
    return {}
  else
    return data
  end
  def get_bonsai_asset(name)
    self.class.get_bonsai_asset(name)
  end
end
