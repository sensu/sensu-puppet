require 'spec_helper_acceptance'

describe 'sensu_plugin', if: RSpec.configuration.sensu_full do
  agent = hosts_as('sensu_agent')[0]
  before do
    if fact_on(agent, 'operatingsystem') == 'Debian'
      skip("TODO: package is missing on Debian - See https://github.com/sensu/sensu-plugins-omnibus/issues/3")
    end
  end
  context 'install plugin' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::agent
      include ::sensu::plugins
      sensu_plugin { 'cpu-checks':
        ensure  => 'present',
        version => '2.0.0',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(agent, pp, :catch_failures => true)
      apply_manifest_on(agent, pp, :catch_changes  => true)
    end

    it 'should have plugin installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-plugins-cpu-checks \(2.0.0\)/)
      end
    end
  end

  context 'install plugin latest version' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::agent
      include ::sensu::plugins
      sensu_plugin { 'cpu-checks':
        ensure  => 'present',
        version => 'latest',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(agent, pp, :catch_failures => true)
      apply_manifest_on(agent, pp, :catch_changes  => true)
    end

    it 'should have plugin installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).not_to match(/^sensu-plugins-cpu-checks \(2.0.0\)/)
        expect(stdout).to match(/^sensu-plugins-cpu-checks/)
      end
    end
  end

  context 'uninstall plugin' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::agent
      include ::sensu::plugins
      sensu_plugin { 'cpu-checks':
        ensure  => 'absent',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(agent, pp, :catch_failures => true)
      apply_manifest_on(agent, pp, :catch_changes  => true)
    end

    it 'should have plugin uninstalled' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).not_to match(/^sensu-plugins-cpu-checks/)
      end
    end
  end
end
