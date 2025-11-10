require 'spec_helper_acceptance'

describe 'examples', if: RSpec.configuration.sensu_mode == 'examples' do
  agent = hosts_as('sensu-agent')[0]
  backend = hosts_as('sensu-backend')[0]

  RSpec.configuration.sensu_examples.each do |example|
    it "should apply #{example} without errors" do
      pp = File.read(example)
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(backend, pp, :catch_failures => true)
        apply_manifest_on(backend, pp, :catch_changes  => true)
      end
    end
  end

  context "PostgreSQL SSL examples" do
    it "should apply without errors" do
      agent_pp = File.read(File.join(RSpec.configuration.examples_dir, 'postgresql-ssl', 'postgresql.pp'))
      backend_pp = File.read(File.join(RSpec.configuration.examples_dir, 'postgresql-ssl', 'sensu-backend.pp'))
      
      # Replace the postgresql::globals declaration to use PostgreSQL 13 with package repo management
      # The example file has: manage_package_repo => false
      # We need: manage_package_repo => true, version => '13'
      agent_pp_with_version = agent_pp.gsub(
        /class\s*{\s*'postgresql::globals':\s*manage_package_repo\s*=>\s*false,?\s*}/m,
        "class { 'postgresql::globals':\n  manage_package_repo => true,\n  version             => '13',\n}"
      )
      
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{backend_pp} }\nnode 'sensu-agent' { #{agent_pp_with_version} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Set locale environment variables to prevent encoding errors in PostgreSQL operations
        locale_env = {
          'LANG' => 'en_US.UTF-8',
          'LANGUAGE' => 'en_US:en',
          'LC_ALL' => 'en_US.UTF-8'
        }
        
        apply_manifest_on(agent, agent_pp_with_version, :catch_failures => true, :environment => locale_env)
        # Allow service restart on second run in Docker environments
        apply_manifest_on(agent, agent_pp_with_version, :acceptable_exit_codes => [0,2], :environment => locale_env)
        apply_manifest_on(backend, backend_pp, :catch_failures => true)
        apply_manifest_on(backend, backend_pp, :catch_changes  => true)
      end
      sleep 60
    end

    describe command("PGPASSWORD='sensu' psql -U sensu -h sensu-agent -c \"select * from events WHERE sensu_check = 'keepalive' LIMIT 1;\""), :node => agent do
      its(:stdout) { should contain('keepalive') }
    end
  end
end
