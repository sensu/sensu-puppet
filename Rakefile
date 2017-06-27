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
  Dir['Vagrantfile', 'spec/**/*.rb', 'lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /^(spec\/fixtures)|(lib)/
  end

  Dir['**/*.sh'].each do |shell_script|
    sh "bash -n #{shell_script}" unless shell_script =~ /spec\/fixtures/
  end
end
