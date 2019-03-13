require 'spec_helper_acceptance'

describe 'sensu::plugins class', unless: RSpec.configuration.sensu_cluster do
  agent = hosts_as('sensu_agent')[0]
  backend = hosts_as('sensu_backend')[0]
  before do
    if fact_on(agent, 'operatingsystem') == 'Debian'
      skip("TODO: package is missing on Debian - See https://github.com/sensu/sensu-plugins-omnibus/issues/3")
    end
  end
  context 'on agent' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { '::sensu': }
      class { '::sensu::agent':
        backends    => ['sensu_backend:8081'],
        config_hash => {
          'name' => 'sensu_agent',
        }
      }
      class { '::sensu::plugins':
        plugins => ['disk-checks'],
        extensions => ['ruby-hash']
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(agent, pp, :catch_failures => true)
      apply_manifest_on(agent, pp, :catch_changes  => true)
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
      class { '::sensu': }
      class { '::sensu::backend':
        password     => 'P@ssw0rd!',
        old_password => 'supersecret',
      }
      class { '::sensu::plugins':
        plugins => ['disk-checks'],
        extensions => ['ruby-hash']
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(backend, pp, :catch_failures => true)
      apply_manifest_on(backend, pp, :catch_changes  => true)
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
