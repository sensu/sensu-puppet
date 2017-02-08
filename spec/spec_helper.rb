require 'puppetlabs_spec_helper/module_spec_helper'

case ENV['COVERAGE']
when 'SimpleCov'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/fixtures/'
    add_filter '/spec/'
  end
when 'rspec-puppet'
  at_exit { RSpec::Puppet::Coverage.report! }
end
