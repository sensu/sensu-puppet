require 'serverspec'

set :backend, :cmd

RSpec.configure do |c|
  c.formatter = :documentation
end
