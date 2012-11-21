require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_clean_config).provide(:json) do
  confine :feature => :json

  def conf
    begin
      @conf ||= JSON.parse(File.read('/etc/sensu/config.json'))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open('/etc/sensu/config.json', 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def destroy
    conf.delete 'checks' if @conf.has_key? 'checks'
    conf.delete 'handlers' if @conf.has_key? 'handlers'
    conf.delete 'client' if @conf.has_key? 'client'
  end

  def exists?
    conf.has_key? 'checks' or conf.has_key? 'handlers' or conf.has_key? 'client'
  end
end
