#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'
require 'tempfile'

def sensuctl_create(name, spec, namespace)
  data = {
    type: "Silenced",
    api_version: "core/v2",
    metadata: { name: name, namespace: namespace },
    spec: spec
  }
  f = Tempfile.new('sensuctl')
  f.write(JSON.pretty_generate(data))
  f.close
  _stdout, stderr, status = Open3.capture3('sensuctl', 'create', '-f', f.path)
  raise Puppet::Error, stderr if status != 0
  { status: "sensuctl create successful" }
end

def delete(name, namespace)
  _stdout, stderr, status = Open3.capture3('sensuctl', 'silenced', 'delete', name, '--skip-confirm', '--namespace', namespace)
  raise Puppet::Error, stderr if status != 0
  { status: "delete successful" }
end

begin
  params = JSON.parse(STDIN.read)
  action = params['action']
  subscription = params['subscription']
  check = params['check']
  namespace = params['namespace'] || 'default'

  if subscription && check
    name = "#{subscription}:#{check}"
  elsif check
    name = "*:#{check}"
  elsif subscription
    name = "#{subscription}:*"
  else
    raise Puppet::Error, "must provide subscription and/or check"
  end

  case action
  when 'delete'
    result = delete(name, namespace)
  else
    spec = {
      check: check,
      subscription: subscription,
      begin: params['begin'],
      expire: params['expire'].nil? ? -1 : params['expire'],
      expire_on_resolve: params['expire_on_resolve'].nil? ? false : params['expire_on_resolve'],
      creator: params['creator'],
      reason: params['reason'],
    }
    result = sensuctl_create(name, spec, namespace)
  end
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
