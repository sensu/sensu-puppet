#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'tempfile'

begin
  params = JSON.parse(STDIN.read)
  check = params['check']
  subscription = params['subscription']
  namespace = params['namespace'] || 'default'
  reason = params['reason']

  cmd = ['sensuctl','check','execute',check,'--namespace',namespace]
  if subscription
    cmd << '--subscriptions'
    cmd << subscription
  end
  if reason
    cmd << '--reason'
    cmd << reason
  end
  stdout, stderr, status = Open3.capture3(cmd.join(' '))
  if status != 0
    raise Exception, "Failed to execute #{cmd.join(' ')}: #{stdout + stderr}"
  end

  puts({ status: "check execute successful" }.to_json)
rescue Exception => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
exit 0
