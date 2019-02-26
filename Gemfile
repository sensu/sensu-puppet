source ENV['GEM_SOURCE'] || "https://rubygems.org"

if puppetversion = ENV['PUPPET_GEM_VERSION'] || "~> 5.x"
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

group :development, :unit_tests do
  gem 'rake'
  gem 'rspec-puppet',                                     :require => false
  gem 'rspec-puppet-facts',                               :require => false
  gem 'rspec-mocks',                                      :require => false
  gem 'puppetlabs_spec_helper',                           :require => false
  gem 'metadata-json-lint',                               :require => false
  gem 'puppet-blacksmith',                                :require => false
  gem 'json',                                             :require => false
  gem 'json_pure',                                        :require => false
  gem 'rest-client',                                      :require => false
  gem 'puppet-lint',                                      :require => false
  gem 'puppet-lint-absolute_classname-check',             :require => false
  gem 'puppet-lint-alias-check',                          :require => false
  gem 'puppet-lint-anchor-check',                         :require => false
  gem 'puppet-lint-empty_string-check',                   :require => false
  gem 'puppet-lint-file_ensure-check',                    :require => false
  gem 'puppet-lint-leading_zero-check',                   :require => false
  gem 'puppet-lint-param-docs',                           :require => false
  gem 'puppet-lint-resource_reference_syntax',            :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check', :require => false
  gem 'puppet-lint-trailing_comma-check',                 :require => false
  gem 'puppet-lint-undef_in_function-check',              :require => false
  gem 'puppet-lint-unquoted_string-check',                :require => false
  gem 'puppet-lint-variable_contains_upcase',             :require => false
  gem 'puppet-lint-version_comparison-check',             :require => false
end

group :documentation do
  gem 'yard',           require: false
  gem 'redcarpet',      require: false
  gem 'puppet-strings', require: false
end

group :system_tests do
  gem 'beaker',                       :require => false
  gem 'beaker-docker',                :require => false
  gem 'beaker-module_install_helper', :require => false
  gem 'beaker-puppet',                :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'beaker-rspec',                 :require => false
  gem 'serverspec',                   :require => false
end

group :development do
  gem 'simplecov',  :require => false
  gem 'guard-rake', :require => false
  gem 'listen',     :require => false
end
# vim:ft=ruby
