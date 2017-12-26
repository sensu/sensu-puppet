source ENV['GEM_SOURCE'] || "https://rubygems.org"

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

group :development, :unit_tests do
  gem 'rake',                                             '< 11.0.0'
  gem 'rspec-puppet', '~> 2.5.0',                         :require => false
  gem 'rspec-mocks',                                      :require => false
  gem 'puppetlabs_spec_helper', '>= 2.0.0',               :require => false
  gem 'puppet-lint', "~> 2.0",                            :require => false
  gem 'json', "~> 1.8.3",                                 :require => false
  gem 'json_pure', "~> 1.8.3",                            :require => false
  gem 'metadata-json-lint',                               :require => false
  gem 'puppet-blacksmith',                                :require => false
  gem 'rest-client', ">= 1.7.4",                          :require => false
  gem 'puppet-lint-absolute_classname-check',             :require => false
  gem 'puppet-lint-alias-check',                          :require => false
  gem 'puppet-lint-empty_string-check',                   :require => false
  gem 'puppet-lint-file_ensure-check',                    :require => false
  gem 'puppet-lint-leading_zero-check',                   :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check', :require => false
  gem 'puppet-lint-trailing_comma-check',                 :require => false
  gem 'puppet-lint-undef_in_function-check',              :require => false
  gem 'puppet-lint-unquoted_string-check',                :require => false
  gem 'puppet-lint-variable_contains_upcase',             :require => false
  gem 'puppet-lint-version_comparison-check',             :require => false
  if puppetversion < '5.0'
    gem 'semantic_puppet', :require => false
  end
end

group :documentation do
  gem 'yard',           require: false
  gem 'redcarpet',      require: false
  gem 'puppet-strings', require: false
end

group :system_tests do
  gem 'beaker-rspec',    :require => false
  gem 'serverspec',      :require => false
  gem 'vagrant-wrapper', :require => false
end

group :development do
  gem 'simplecov',          :require => false
  gem 'guard-rake',         :require => false
  gem 'listen', '~> 3.0.0', :require => false
end

if File.exists? 'Gemfile.local'
  eval(File.read('Gemfile.local'), binding)
end

# vim:ft=ruby
