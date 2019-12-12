#!/opt/puppetlabs/puppet/bin/ruby
require 'resolv'
require 'json'
require 'open3'

class SensuResolveReference
  def self.is_ip?(ip)
    !!(ip =~ Resolv::IPv4::Regex)
  end

  def self.sensuctl_entities(namespace)
    cmd = ['sensuctl','entity','list','--format','json']
    if namespace
      cmd << '--namespace'
      cmd << namespace
    end
    stdout, stderr, status = Open3.capture3(cmd.join(' '))
    if status != 0
      raise Exception, "Failed to execute #{cmd.join(' ')}: #{stdout + stderr}"
    end
    entities = JSON.parse(stdout)
    entities
  end

  def self.entities_to_targets(entities, interface_list, uri_ipaddress)
    targets = []
    entities.each do |e|
      target = {}
      target['name'] = e['metadata']['name']
      # Get IP address for URI
      # If interface_list was defined then find first match
      # If interface_list not defined and only one interface, use that as ipaddress
      # If interface_list not defined and more than one interface, use name
      ipaddress = target['name']
      interface_address = {}
      e['system']['network']['interfaces'].each do |i|
        i['addresses'].each do |a|
          address = a.split('/')[0]
          next unless is_ip?(address)
          next if address =~ /^127/
          interface_address[i['name']] = address
          break
        end
      end
      if interface_list
        interface_list.each do |i|
          if interface_address.key?(i)
            ipaddress = interface_address[i]
            break
          end
        end
      else
        if interface_address.keys.size == 1
          i = interface_address.keys[0]
          ipaddress = interface_address[i]
        end
      end
      target['uri'] = ipaddress
      targets << target
    end
    targets
  end

  def self.resolve_reference(params)
    namespace = params['namespace']
    subscription = params['subscription']
    interface_list = params['interface_list']
    uri_ipaddress = params['uri_ipaddress']

    entities = sensuctl_entities(namespace)

    if subscription
      entities.select! { |e| e['subscriptions'].include?(subscription) }
    end

    targets = entities_to_targets(entities, interface_list, uri_ipaddress)
    targets
  end

  def self.run
    params = JSON.parse(STDIN.read)

    targets = resolve_reference(params)

    puts({ value: targets }.to_json)

  rescue Exception => e
    puts({ _error: e.message }.to_json)
    exit 1
  end
end

SensuResolveReference.run if $PROGRAM_NAME == __FILE__

