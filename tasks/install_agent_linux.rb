#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'
require 'tempfile'

begin
  params = JSON.parse(STDIN.read)
  backend = params['backend']
  if backend.is_a?(String)
    backend = [backend]
  end
  subscription = params['subscription']
  if subscription.is_a?(String)
    subscription = [subscription]
  end
  namespace = params['namespace'] || 'default'
  backends_param = backend.map { |b| "'#{b}'" }.join(',')
  subscriptions_param = subscription.map { |b| "'#{b}'" }.join(',')

  puppet = '/opt/puppetlabs/bin/puppet'
  _stdout, stderr, status = Open3.capture3(puppet,'module','install','sensu-sensu')
  if status != 0
    raise Puppet::Error, "Failed to execute install sensu-sensu: #{_stdout + _stderr}"
  end

  `which apt 2>/dev/null 1>/dev/null`
  if $?.success?
    _stdout, stderr, status = Open3.capture3(puppet,'module','install','puppetlabs-apt')
    if status != 0
      raise Puppet::Error, "Failed to execute install puppetlabs-apt: #{_stdout + _stderr}"
    end
  end
  f = Tempfile.new('manifest')
  manifest = <<-EOS
class { '::sensu':
  use_ssl => false,
}
class { '::sensu::agent':
  backends    => [#{backends_param}],
  config_hash => {
    'subscriptions' => [#{subscriptions_param}],
    'namespace'     => '#{namespace}',
  },
}
EOS
  f.write(manifest)
  f.close
  _stdout, stderr, status = Open3.capture3(puppet,'apply',f.path)
  if status != 0
    raise Puppet::Error, "Failed to execute install sensu-sensu: #{_stdout + _stderr}"
  end

  puts({ status: "install agent successful" }.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end

