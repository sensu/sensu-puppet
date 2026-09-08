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
  # facterdb's jgrep dependency calls the legacy JSON.create_id= setter, removed in json 3.0+.
  # jgrep 1.5.4 is its latest release, with no fix upstream. Only rspec-puppet-facts/facterdb
  # need this, so pin it here rather than for every bundle context.
  gem 'json', '< 3.0',                                             :require => false
  gem 'rspec-mocks',                                               :require => false
  gem 'parallel_tests',                                            :require => false
  gem 'puppetlabs_spec_helper',                                    :require => false
  gem 'puppetlabs-syntax',                                         :require => false
  gem 'rspec-github',                                              :require => false
  gem 'metadata-json-lint',                                        :require => false
  gem 'puppet-blacksmith',                                         :require => false
  gem 'puppet-lint',                                               :require => false
  gem 'puppet-lint-absolute_classname-check',                      :require => false
  gem 'puppet-lint-alias-check',                                   :require => false
  gem 'puppet-lint-anchor-check',                                  :require => false
  gem 'puppet-lint-file_ensure-check',                             :require => false
  gem 'puppet-lint-leading_zero-check',                            :require => false
  gem 'puppet-lint-param-docs',                                    :require => false
  gem 'puppet-lint-resource_reference_syntax',                     :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check',          :require => false
  gem 'puppet-lint-topscope-variable-check',                       :require => false
  gem 'puppet-lint-trailing_comma-check',                          :require => false
  gem 'puppet-lint-unquoted_string-check',                         :require => false
  gem 'puppet-lint-variable_contains_upcase',                      :require => false
  gem 'puppet-lint-version_comparison-check',                      :require => false
  gem 'rubocop', '~> 1.65',                                        :require => false
  gem 'rubocop-i18n', '~> 3.0',                                    :require => false
  gem 'rubocop-rspec', '~> 3.0',                                   :require => false
  gem 'syslog',                                                    :require => false
end

group :documentation do
  gem 'yard',           require: false
  gem 'redcarpet',      require: false
  gem 'puppet-strings', require: false
  gem 'github_changelog_generator', require: false
end

group :system_tests do
  gem 'beaker',                       '7.7.0',  :require => false
  gem 'beaker-docker',                '3.1.3',  :require => false
  gem 'beaker-module_install_helper', '0.1.7',  :require => false
  gem 'beaker-puppet',                '4.4.3',  :require => false
  gem 'beaker-puppet_install_helper', '0.9.4',  :require => false
  gem 'beaker-rspec',                 '9.1.0',  :require => false
  gem 'serverspec',                   '2.43.0', :require => false
  gem 'simp-beaker-helpers',          '3.1.1',  :require => false
  # puppet requires ffi at runtime on Windows; it is not in puppet's gemspec so
  # bundler won't include it when BUNDLE_WITHOUT=development excludes the listen chain
  gem 'ffi',                                    :require => false
end

group :development do
  gem 'simplecov',  :require => false
  gem 'guard-rake', :require => false
  gem 'listen',     :require => false
end
# vim:ft=ruby
