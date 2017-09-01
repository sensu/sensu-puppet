require 'json'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

begin
  require 'puppet_blacksmith/rake_tasks'
rescue
end

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_140chars")
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.relative = true

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc 'Validate manifests, templates, ruby files and shell scripts'
task :validate do
  # lib/* gets checked by puppetlabs_spec_helper, though it skips spec entirely
  puts "\nValidating ruby files ignored by puppetlabs_spec_helper (Vagrantfile', 'spec/**/*.rb)"
  Dir['Vagrantfile', 'spec/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end

  puts "\nValidating shell scripts (**/.*.sh)"
  Dir['**/*.sh'].each do |shell_script|
    sh "bash -n #{shell_script}" unless shell_script =~ /spec\/fixtures/
  end

  puts "\nValidating JSON files (spec/fixtures/unit/**/*.json)"
  Dir['spec/fixtures/unit/**/*.json'].each do |json_file|
    puts json_file
    file = File.read(json_file)
    JSON.parse(file)
  end
end

# Puppet Strings (Documentation generation from inline comments)
# See: https://github.com/puppetlabs/puppet-strings#rake-tasks
require 'puppet-strings/tasks'

desc 'Alias for strings:generate'
task :doc => ['strings:generate']
