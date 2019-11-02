#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'tempfile'

begin
  params = JSON.parse(STDIN.read)
  namespace = params['namespace']

  cmd = ['sensuctl','asset','outdated','--format','json']
  if namespace
    cmd << '--namespace'
    cmd << namespace
  else
    cmd << '--all-namespaces'
  end
  stdout, stderr, status = Open3.capture3(cmd.join(' '))
  if status != 0
    raise Exception, "Failed to execute #{cmd.join(' ')}: #{stdout + stderr}"
  end
  data = JSON.parse(stdout)

  puts({ status: "command executed successfully", data: data }.to_json)
rescue Exception => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
exit 0
