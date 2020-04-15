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
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{backend_pp} }\nnode 'sensu-agent' { #{agent_pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(agent, agent_pp, :catch_failures => true)
        apply_manifest_on(agent, agent_pp, :catch_changes  => true)
        apply_manifest_on(backend, backend_pp, :catch_failures => true)
        apply_manifest_on(backend, backend_pp, :catch_changes  => true)
      end
      sleep 5
    end

    describe command("PGPASSWORD='sensu' psql -U sensu -h sensu-agent -c \"select * from events WHERE sensu_check = 'keepalive' LIMIT 1;\""), :node => agent do
      its(:stdout) { should contain('keepalive') }
    end
  end
end
