require 'serverspec'

set :backend, :cmd

# bundle exec sets RUBYOPT=-r bundler/setup for the test runner (Ruby 3.4).
# The system Puppet's embedded Ruby (a different Ruby version) inherits this,
# causing Puppet to look for gems in the test runner's vendor/bundle/ruby/3.4.0
# path. That bundle's native gems (like ffi) are compiled for Ruby 3.4, not
# Puppet's embedded Ruby, so `require 'ffi'` fails and puppet apply exits 1.
# Clearing RUBYOPT here is safe: bundler/setup already ran for this process,
# so LOAD_PATH is set; clearing only affects subprocess environment.
ENV.delete('RUBYOPT') if Gem.win_platform?

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
