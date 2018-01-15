require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_enterprise_dashboard_config).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ProviderCreate

  # Internal: Retrieve the current contents of /etc/sensu/dashboard.json
  #
  # Returns a Hash representation of the JSON structure in
  # /etc/sensu/dashboard.json or an empty Hash if the file can not be read.
  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  # Public: Save changes to the Dashboard section of /etc/sensu/dashboard.json to disk.
  #
  # Returns nothing.
  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def pre_create
    conf['dashboard'] = {}
  end

  # Public: Remove the Dashboard configuration section.
  #
  # Returns nothing.
  def destroy
    conf.delete 'dashboard'
  end

  # Public: Determine if the Dashboard configuration section is present.
  #
  # Returns a Boolean, true if present, false if absent.
  def exists?
    conf.has_key? 'dashboard'
  end

  def config_file
    "#{resource[:base_path]}/dashboard.json"
  end

  # Public: Retrieve the hostname that the Dashboard is configured to listen on.
  #
  # Returns the String hostname.
  def host
    conf['dashboard']['host']
  end

  # Public: Set the hostname that the Dashboard should listen on.
  #
  # Returns nothing.
  def host=(value)
    conf['dashboard']['host'] = value
  end

  # Public: Retrieve the port number that the Dashboard is configured to listen on.
  #
  # Returns the String port number.
  def port
    conf['dashboard']['port'].to_s
  end

  # Public: Set the port that the Dashboard should listen on.
  #
  # Returns nothing.
  def port=(value)
    conf['dashboard']['port'] = value.to_i
  end

  # Public: Retrieve the refresh rate
  #
  # Returns the String refresh rate
  def refresh
    conf['dashboard']['refresh'].to_s
  end

  # Public: Set the refresh rate for the Dashboard
  #
  # Returns nothing.
  def refresh=(value)
    conf['dashboard']['refresh'] = value.to_i
  end

  # Public: Retrieve the Dashboard username
  #
  # Returns the String hostname.
  def user
    conf['dashboard']['user']
  end

  # Public: Set the Dashboard user
  #
  # Returns nothing.
  def user=(value)
    conf['dashboard']['user'] = value
  end

  # Public: Retrieve the password for the Dashboard
  #
  # Returns the String password.
  def pass
    conf['dashboard']['pass']
  end

  # Public: Set the Dashboard password
  #
  # Returns nothing.
  def pass=(value)
    conf['dashboard']['pass'] = value
  end

  # Public: Retrieve the auth hash for the dashboard
  #
  # Returns the auth config
  def auth
    conf['dashboard']['auth']
  end

  # Public: Set the auth config
  #
  # Returns nothing.
  def auth=(value)
    conf['dashboard']['auth'] = value.to_hash
  end

  # Public: Set the ssl listener config
  #
  # Returns nothing.
  def ssl=(value)
    conf['dashboard']['ssl'] = value
  end

  # Public: Get the Dashboard ssl
  #
  # Returns the ssl listener config
  def ssl
    conf['dashboard']['ssl']
  end

  # Public: Set the audit config
  #
  # Returns nothing.
  def audit=(value)
    conf['dashboard']['audit'] = value
  end

  # Public: Get the Dashboard audit config
  #
  # Returns the audit config
  def audit
    conf['dashboard']['audit']
  end

  # Public: Retrieve the Github config
  #
  # Returns the Github auth config
  def github
    conf['dashboard']['github']
  end

  # Public: Set the Github config hash
  #
  # Returns nothing.
  def github=(value)
    conf['dashboard']['github'] = value.to_hash
  end

  # Public: Retrieve the GitLab config
  #
  # Returns the GitLab auth config
  def gitlab
    conf['dashboard']['gitlab']
  end

  # Public: Set the GitLab config hash
  #
  # Returns nothing.
  def gitlab=(value)
    conf['dashboard']['gitlab'] = value.to_hash
  end

  # Public: Retrieve the LDAP config
  #
  # Returns the LDAP auth config
  def ldap
    conf['dashboard']['ldap']
  end

  # Public: Set the LDAP config hash
  #
  # Returns nothing.
  def ldap=(value)
    conf['dashboard']['ldap'] = value.to_hash
  end

  # Public: Retrieve the OIDC config
  #
  # Returns the OIDC auth config
  def oidc
    conf['dashboard']['oidc']
  end

  # Public: Set the OIDC config hash
  #
  # Returns nothing.
  def oidc=(value)
    conf['dashboard']['oidc'] = value.to_hash
  end
end
