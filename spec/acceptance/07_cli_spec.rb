require 'spec_helper_acceptance'

describe 'sensu::cli class', if: ['base','full'].include?(RSpec.configuration.sensu_mode) do
  node = hosts_as('sensu-agent')[0]
  backend = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        api_host => 'sensu-backend',
        password => 'P@ssw0rd!',
      }
      class { 'sensu::cli': }
      EOS
      backend_pp = <<-EOS
      class { '::sensu':
        password => 'P@ssw0rd!',
      }
      class { 'sensu::backend': }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<-EOS
          node 'sensu-agent' { #{pp} }
          node 'sensu-backend' { #{backend_pp} }
        EOS
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(backend, backend_pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe package('sensu-go-cli'), :node => node do
      it { should be_installed }
    end

    it 'should have working sensuctl' do
      exit_code = on(node, 'sensuctl cluster health').exit_code
      expect(exit_code).to eq(0)
    end
  end

  context 'handles changed password' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        api_host => 'sensu-backend',
        password => 'supersecret',
      }
      class { 'sensu::cli': }
      EOS
      backend_pp = <<-EOS
      class { '::sensu':
        password => 'supersecret',
      }
      class { 'sensu::backend': }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<-EOS
          node 'sensu-agent' { #{pp} }
          node 'sensu-backend' { #{backend_pp} }
        EOS
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(backend, backend_pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have working sensuctl' do
      exit_code = on(node, 'sensuctl cluster health').exit_code
      expect(exit_code).to eq(0)
    end
  end

  context 'handles no SSL' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        use_ssl  => false,
        api_host => 'sensu-backend',
        password => 'P@ssw0rd!',
      }
      class { 'sensu::cli': }
      EOS
      backend_pp = <<-EOS
      class { '::sensu':
        use_ssl  => false,
        password => 'P@ssw0rd!',
      }
      class { 'sensu::backend': }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<-EOS
          node 'sensu-agent' { #{pp} }
          node 'sensu-backend' { #{backend_pp} }
        EOS
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(backend, backend_pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have working sensuctl' do
      exit_code = on(node, 'sensuctl cluster health').exit_code
      expect(exit_code).to eq(0)
    end
  end
end
