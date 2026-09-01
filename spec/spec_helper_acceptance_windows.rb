require 'serverspec'

set :backend, :cmd

if Gem.win_platform?
  # bundle exec prepends vendor/bundle/ruby/3.4.0/bin to PATH, so the bundled
  # puppet binstub wins over system puppet. Prepend the system Puppet bin dir
  # so tests invoke the installed puppet-agent (with its own embedded Ruby and
  # native ffi) rather than the gem from the test bundle.
  # Also clear RUBYOPT so puppet's embedded Ruby doesn't inherit -r bundler/setup.
  ENV['PATH'] = "C:\\Program Files\\Puppet Labs\\Puppet\\bin#{File::PATH_SEPARATOR}#{ENV['PATH']}"
  ENV.delete('RUBYOPT')
end

RSpec.configure do |c|
  c.formatter = :documentation
end
