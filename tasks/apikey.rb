#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def create(username)
  stdout, stderr, status = Open3.capture3('sensuctl', 'api-key', 'grant', username)
  raise Puppet::Error, stderr if status != 0
  key = stdout.split('/')[-1]
  { status: "successful", key: key }
end

def list()
  stdout, stderr, status = Open3.capture3('sensuctl', 'api-key', 'list', '--format', 'json')
  raise Puppet::Error, stderr if status != 0
  { status: "success", keys: JSON.parse(stdout) }
end

def delete(key)
  stdout, stderr, status = Open3.capture3('sensuctl', 'api-key', 'revoke', key, '--skip-confirm')
  raise Puppet::Error, stderr if status != 0
  { status: "delete successful" }
end

begin
  params = JSON.parse(STDIN.read)
  action = params['action']
  username = params['username']
  key = params['key']

  case action
  when 'create'
    raise Puppet::Error, "username is required for action=create" if username.nil?
    result = create(username)
  when 'list'
    result = list()
  when 'delete'
    raise Puppet::Error, "key is required for action=delete" if key.nil?
    result = delete(key)
  end
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
