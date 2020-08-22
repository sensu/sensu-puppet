require 'spec_helper_acceptance'

describe 'sensu::plugins class', if: ['base','full'].include?(RSpec.configuration.sensu_mode) do
  agent = hosts_as('sensu-agent')[0]
  backend = hosts_as('sensu-backend')[0]
  context 'on agent' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { '::sensu': }
      class { 'sensu::agent':
        backends    => ['sensu-backend:8081'],
        entity_name => 'sensu-agent',
      }
      class { 'sensu::plugins':
        plugins => ['disk-checks'],
        extensions => ['ruby-hash']
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(agent, pp, :catch_failures => true)
        apply_manifest_on(agent, pp, :catch_changes  => true)
      end
    end

    describe package('sensu-plugins-ruby'), :node => agent do
      it { should be_installed }
    end

    it 'should have plugin installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-plugins-disk-checks/)
      end
    end

    it 'should have extension installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-extensions-ruby-hash/)
      end
    end
  end
  context 'on backend' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { '::sensu':
        password => 'P@ssw0rd!',
      }
      class { 'sensu::backend': }
      class { 'sensu::plugins':
        plugins => ['disk-checks'],
        extensions => ['ruby-hash']
      }
      EOS

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

    describe package('sensu-plugins-ruby'), :node => backend do
      it { should be_installed }
    end

    it 'should have plugin installed' do
      on backend, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-plugins-disk-checks/)
      end
    end

    it 'should have extension installed' do
      on backend, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-extensions-ruby-hash/)
      end
    end
  end
end
