source ENV['GEM_SOURCE'] || 'https://rubygems.org'

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
  gem 'rake'
  gem 'rspec-puppet',                                              :require => false
  gem 'rspec-puppet-facts',                                        :require => false
  gem 'rspec-mocks',                                               :require => false
  gem 'parallel_tests',                                            :require => false
  gem 'puppetlabs_spec_helper',                                    :require => false
  gem 'metadata-json-lint',                                        :require => false
  gem 'puppet-blacksmith',                                         :require => false
  gem 'puppet-lint',                                               :require => false
  gem 'puppet-lint-absolute_classname-check',                      :require => false
  gem 'puppet-lint-alias-check',                                   :require => false
  gem 'puppet-lint-anchor-check',                                  :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check', :require => false
  gem 'puppet-lint-empty_string-check',                            :require => false
  gem 'puppet-lint-empty_trailing_lines',                          :require => false
  gem 'puppet-lint-file_ensure-check',                             :require => false
  gem 'puppet-lint-leading_zero-check',                            :require => false
  gem 'puppet-lint-legacy_facts-check',                            :require => false
  gem 'puppet-lint-no_symbolic_file_modes-check',                  :require => false
  gem 'puppet-lint-param-docs',                                    :require => false
  gem 'puppet-lint-resource_reference_syntax',                     :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check',          :require => false
  gem 'puppet-lint-top_scope_facts-check',                         :require => false
  gem 'puppet-lint-topscope-variable-check',                       :require => false
  gem 'puppet-lint-trailing_comma-check',                          :require => false
  gem 'puppet-lint-trailing_newline-check',                        :require => false
  gem 'puppet-lint-undef_in_function-check',                       :require => false
  gem 'puppet-lint-unquoted_string-check',                         :require => false
  gem 'puppet-lint-variable_contains_upcase',                      :require => false
  gem 'puppet-lint-version_comparison-check',                      :require => false
  gem 'rubocop', '~> 0.49.0',                                      :require => false
  gem 'rubocop-i18n', '~> 1.2.0',                                  :require => false
  gem 'rubocop-rspec', '~> 1.16.0',                                :require => false
  if Gem.win_platform? && ENV['PUPPET_GEM_VERSION'] =~ /6.x/
    gem 'ffi', '~>1.11.0', :require => false
  end
end

group :documentation do
  gem 'yard',           require: false
  gem 'redcarpet',      require: false
  gem 'puppet-strings', require: false
  gem 'github_changelog_generator', require: false
end

group :system_tests do
  gem 'beaker',                       :require => false
  gem "beaker-docker",                :require => false
  gem 'beaker-module_install_helper', :require => false
  gem 'beaker-puppet',                :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'beaker-rspec',                 :require => false
  gem 'serverspec',                   :require => false
  gem 'simp-beaker-helpers',          :require => false
end

group :development do
  gem 'simplecov',  :require => false
  gem 'guard-rake', :require => false
  gem 'listen',     :require => false
end
# vim:ft=ruby
