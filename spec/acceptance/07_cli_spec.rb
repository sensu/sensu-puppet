require 'spec_helper_acceptance'

describe 'sensu::cli class', unless: RSpec.configuration.sensu_cluster do
  node = hosts_as('sensu_agent')[0]
  backend = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu': }
      class { '::sensu::cli':
        url_host => 'sensu_backend',
        password => 'P@ssw0rd!',
      }
      EOS
      backend_pp = <<-EOS
      class { '::sensu::backend':
        password      => 'P@ssw0rd!',
        old_password  => 'supersecret',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<-EOS
          node 'sensu_agent' { #{pp} }
          node 'sensu_backend' { #{backend_pp} }
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
      class { '::sensu::cli':
        url_host => 'sensu_backend',
        password => 'supersecret',
      }
      EOS
      backend_pp = <<-EOS
      class { '::sensu::backend':
        password      => 'supersecret',
        old_password  => 'P@ssw0rd!',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<-EOS
          node 'sensu_agent' { #{pp} }
          node 'sensu_backend' { #{backend_pp} }
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

  # TODO: Remove this once changing SSL and passwords can be done at same time
  # Currently changing SSL and password at same time does not work
  context 'reset password' do
    it 'should work without errors' do
      backend_pp = <<-EOS
      class { '::sensu::backend':
        password     => 'P@ssw0rd!',
        old_password => 'supersecret',
      }
      EOS

      apply_manifest_on(backend, backend_pp, :catch_failures => true)
    end
  end

  context 'handles no SSL' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        use_ssl  => false,
      }
      class { '::sensu::cli':
        url_host => 'sensu_backend',
        password => 'P@ssw0rd!',
      }
      EOS
      backend_pp = <<-EOS
      class { '::sensu':
        use_ssl => false,
      }
      class { '::sensu::backend':
        password      => 'P@ssw0rd!',
        old_password  => 'supersecret',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<-EOS
          node 'sensu_agent' { #{pp} }
          node 'sensu_backend' { #{backend_pp} }
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
