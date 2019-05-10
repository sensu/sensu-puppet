require 'serverspec'

set :backend, :cmd

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
