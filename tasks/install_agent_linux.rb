#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'
require 'tempfile'

begin
  params = JSON.parse(STDIN.read)
  backend = params['backend']
  subscription = params['subscription']
  if params['entity_name']
    entity_name = "'#{params['entity_name']}'"
  else
    entity_name = 'undef'
  end
  namespace = params['namespace'] || 'default'
  output = params.fetch('output', false)

  return_output = {}
  puppet = '/opt/puppetlabs/bin/puppet'
  # Install sensu module
  _stdout, _stderr, status = Open3.capture3(puppet,'module','install','sensu-sensu','--color','false')
  return_output['module-install'] = _stdout + _stderr
  if status != 0
    raise Puppet::Error, "Failed to execute install sensu-sensu: #{_stdout + _stderr}"
  end

  # Install apt module for apt systems
  `which apt 2>/dev/null 1>/dev/null`
  if $?.success?
    _stdout, _stderr, status = Open3.capture3(puppet,'module','install','puppetlabs-apt','--color','false')
    return_output['module-install'] = return_output['module-install'] + _stdout + _stderr
    if status != 0
      raise Puppet::Error, "Failed to execute install puppetlabs-apt: #{_stdout + _stderr}"
    end
  end
  return_output['module-install'] = return_output['module-install'].split(/\n/)

  # Apply sensu and sensu::agent classes to actually install Sensu Go Agent
  f = Tempfile.new('manifest')
  manifest = <<-EOS
class { '::sensu':
  use_ssl => false,
}
class { 'sensu::agent':
  backends      => ['#{backend}'],
  subscriptions => ['#{subscription}'],
  entity_name   => #{entity_name},
  namespace     => '#{namespace}',
}
EOS
  return_output['manifest'] = manifest.split(/\n/)
  f.write(manifest)
  f.close
  _stdout, _stderr, status = Open3.capture3(puppet,'apply',f.path,'--color','false')
  return_output['apply'] = (_stdout + _stderr).split(/\n/)
  if status != 0
    raise Puppet::Error, "Failed to execute install sensu-sensu: #{_stdout + _stderr}"
  end

  ret = {status: "install agent successful"}
  ret['output'] = return_output if output
  puts(ret.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
