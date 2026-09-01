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
    end

    # PostgreSQL event store requires a Sensu commercial license.  Skip the
    # events-in-postgres checks when no license is present so the test suite
    # passes on open-source builds; the manifest apply/idempotency above still runs.
    context "events stored in PostgreSQL", if: RSpec.configuration.sensu_test_enterprise do
      it "should have keepalive events stored in PostgreSQL" do
        # Diagnostics: backend log lines mentioning postgres/errors, TCP reachability,
        # PostgreSQL SSL status, and existing tables — all captured before polling.
        on backend, 'journalctl -u sensu-backend --since "3 minutes ago" -n 80 2>/dev/null | grep -iE "postgres|error|fail|connect|dsn" | head -30 || echo "no-relevant-backend-logs"', acceptable_exit_codes: [0, 1]
        on backend, 'bash -c "echo >/dev/tcp/sensu-agent/5432" 2>&1 && echo "port-5432-open" || echo "port-5432-blocked"', acceptable_exit_codes: [0, 1]
        on agent, 'PGPASSWORD=sensu psql -h sensu-agent -U sensu -d sensu -c "show ssl;" 2>&1', acceptable_exit_codes: [0, 1]
        on agent, "PGPASSWORD=sensu psql -h sensu-agent -U sensu -d sensu -c \"SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';\" 2>&1 | head -20", acceptable_exit_codes: [0, 1]
        # Poll up to 60s for the backend to activate the PostgreSQL store and store a keepalive.
        retry_on(agent, "PGPASSWORD='sensu' psql -U sensu -h sensu-agent -c \"SELECT 1 FROM events WHERE sensu_check = 'keepalive' LIMIT 1;\" | grep -q '(1 row)'", max_retries: 12, retry_interval: 5)
      end

      describe command("PGPASSWORD='sensu' psql -U sensu -h sensu-agent -c \"select * from events WHERE sensu_check = 'keepalive' LIMIT 1;\""), :node => agent do
        its(:stdout) { should contain('keepalive') }
      end
    end
  end
end
