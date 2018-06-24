require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_event).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_event using sensuctl"

  mk_resource_methods

  def self.instances
    events = []

    output = sensuctl_list('event')
    Puppet.debug("sensu event: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl event list')
      data = []
    end

    data.each do |d|
      event = {}
      event[:ensure] = :present
      event[:entity] = d['entity']['id']
      event[:check] = d['check']['name']
      event[:name] = "#{event[:check]} for #{event[:entity]}"
      if d['check']['status'] == 0
        event[:ensure] = :resolve
      end
      events << new(event)
    end
    events
  end

  def self.prefetch(resources)
    events = instances
    resources.keys.each do |name|
      if provider = events.find { |e|
          e.check == resources[name][:check] &&
          e.entity == resources[name][:entity]
          }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present || @property_hash[:ensure] == :resolve
  end

  def state
    return @property_hash[:ensure]
  end

  def resolve
    cmd = ['event', 'resolve']
    cmd << resource[:entity]
    cmd << resource[:check]
    if resource[:organization]
      cmd << '--organization'
      cmd << resource[:organization]
    end
    if resource[:environment]
      cmd << '--environment'
      cmd << resource[:environment]
    end
    begin
      sensuctl(cmd)
    rescue Exception => e
      raise Puppet::Error, "sensuctl event resolve #{resource[:entity]} #{resource[:check]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :resolve
  end

  def destroy
    begin
      sensuctl(['event', 'delete', resource[:entity], resource[:check], '--skip-confirm'])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete event #{resource[:entity]} #{resource[:check]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

