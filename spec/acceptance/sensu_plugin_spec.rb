require 'spec_helper_acceptance'

describe 'sensu_plugin', if: RSpec.configuration.sensu_mode == 'types' do
  agent = hosts_as('sensu-agent')[0]
  context 'install plugin' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::agent
      class { 'sensu::plugins':
        gem_dependencies => ['vmstat'],
      }
      sensu_plugin { 'cpu-checks':
        ensure  => 'present',
        version => '2.0.0',
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

    it 'should have plugin installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-plugins-cpu-checks \(2.0.0\)/)
      end
    end

    it 'should have gem installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^vmstat \(/)
      end
    end
  end

  context 'install plugin latest version' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::agent
      include sensu::plugins
      sensu_plugin { 'cpu-checks':
        ensure  => 'present',
        version => 'latest',
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

    it 'should have plugin installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).not_to match(/^sensu-plugins-cpu-checks \(2.0.0\)/)
        expect(stdout).to match(/^sensu-plugins-cpu-checks/)
      end
    end
  end

  context 'downgrade plugin' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::agent
      include sensu::plugins
      sensu_plugin { 'cpu-checks':
        ensure  => 'present',
        version => '2.0.0',
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

    it 'should have plugin installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-plugins-cpu-checks \(2.0.0\)/)
      end
    end
  end

  context 'upgrade plugin' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::agent
      include sensu::plugins
      sensu_plugin { 'cpu-checks':
        ensure  => 'present',
        version => '3.0.0',
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

    it 'should have plugin installed' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).to match(/^sensu-plugins-cpu-checks \(3.0.0\)/)
      end
    end
  end

  context 'uninstall plugin' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::agent
      include sensu::plugins
      sensu_plugin { 'cpu-checks':
        ensure  => 'absent',
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

    it 'should have plugin uninstalled' do
      on agent, '/opt/sensu-plugins-ruby/embedded/bin/gem list --local' do
        expect(stdout).not_to match(/^sensu-plugins-cpu-checks/)
      end
    end
  end
end
