require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_client_subscription).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read("/etc/sensu/conf.d/subscription_#{resource[:name]}.json"))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/subscription_#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    @conf['client'] = {'subscriptions' => [ resource[:name] ] }
  end

  def destroy
    @conf = nil
  end
end
