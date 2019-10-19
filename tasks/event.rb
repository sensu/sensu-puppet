#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def resolve(entity, check, namespace)
  _stdout, stderr, status = Open3.capture3('sensuctl', 'event', 'resolve', entity, check, '--namespace', namespace)
  raise Puppet::Error, stderr if status != 0
  { status: "resolve successful" }
end

def delete(entity, check, namespace)
  _stdout, stderr, status = Open3.capture3('sensuctl', 'event', 'delete', entity, check, '--skip-confirm', '--namespace', namespace)
  raise Puppet::Error, stderr if status != 0
  { status: "delete successful" }
end

begin
  params = JSON.parse(STDIN.read)
  action = params['action']
  entity = params['entity']
  check = params['check']
  namespace = params['namespace'] || 'default'

  case action
  when 'resolve'
    result = resolve(entity, check, namespace)
  when 'delete'
    result = delete(entity, check, namespace)
  end
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
