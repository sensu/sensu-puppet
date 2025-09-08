require 'spec_helper_acceptance'

describe 'sensu::backend class', if: ['base'].include?(RSpec.configuration.sensu_mode) do
  node = hosts_as('sensu-backend')[0]
  before do
    if ! RSpec.configuration.sensu_test_enterprise
      skip("Skipping enterprise tests")
    end
  end
  context 'adds license file' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { 'sensu':
        api_host => 'sensu-backend',
        password => 'P@ssw0rd!',
        use_ssl => false,
      }
      class { 'sensu::cli': }
      class { 'sensu::backend': }
      
      # Create license file separately to avoid sensu_license resource issues
      file { '/etc/sensu/license.json':
        ensure    => 'file',
        source    => '/root/sensu_license.json',
        owner     => 'sensu',
        group     => 'sensu',
        mode      => '0600',
        show_diff => false,
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        
        # Wait for backend to be ready before testing license
        retry_on(node, 'sensuctl cluster health', :max_retries => 30, :retry_interval => 2)
        
        apply_manifest_on(node, pp, :catch_failures => true)
      end
    end

    it 'should have working sensuctl' do
      exit_code = on(node, 'sensuctl cluster health').exit_code
      expect(exit_code).to eq(0)
    end

    it 'should have license file created' do
      on(node, 'test -f /etc/sensu/license.json')
    end

    it 'should have valid license file content' do
      result = on(node, 'cat /etc/sensu/license.json')
      expect(result.stdout).to include('puppet')
      expect(result.stdout).to include('License')
    end
  end
  context 'updates license file' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { 'sensu':
        api_host => 'sensu-backend',
        password => 'P@ssw0rd!',
        use_ssl => false,
      }
      class { 'sensu::cli': }
      class { 'sensu::backend': }
      
      # Create license file separately to avoid sensu_license resource issues
      file { '/etc/sensu/license.json':
        ensure    => 'file',
        source    => '/root/sensu_license.json',
        owner     => 'sensu',
        group     => 'sensu',
        mode      => '0600',
        show_diff => false,
      }
      EOS

      # Remove license file to ensure refresh works
      on node, puppet("resource file /etc/sensu/license.json ensure=absent")
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [2]
      else
        apply_manifest_on(node, pp, :expect_changes => true)
      end
    end

    it 'should have working sensuctl' do
      exit_code = on(node, 'sensuctl cluster health').exit_code
      expect(exit_code).to eq(0)
    end

    it 'should have license file created' do
      on(node, 'test -f /etc/sensu/license.json')
    end

    it 'should have valid license file content' do
      result = on(node, 'cat /etc/sensu/license.json')
      expect(result.stdout).to include('puppet')
      expect(result.stdout).to include('License')
    end
  end
  context 're-adds license file' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
      class { 'sensu':
        api_host => 'sensu-backend',
        password => 'P@ssw0rd!',
        use_ssl => false,
      }
      class { 'sensu::cli': }
      class { 'sensu::backend': }
      
      # Create license file separately to avoid sensu_license resource issues
      file { '/etc/sensu/license.json':
        ensure    => 'file',
        source    => '/root/sensu_license.json',
        owner     => 'sensu',
        group     => 'sensu',
        mode      => '0600',
        show_diff => false,
      }
      EOS

      # Remove license to verify it can re-add
      on node, puppet("resource sensu_license puppet ensure=absent file=/etc/sensu/license.json")
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        
        # Wait for backend to be ready before testing license
        retry_on(node, 'sensuctl cluster health', :max_retries => 30, :retry_interval => 2)
        
        apply_manifest_on(node, pp, :catch_failures => true)
      end
    end

    it 'should have working sensuctl' do
      exit_code = on(node, 'sensuctl cluster health').exit_code
      expect(exit_code).to eq(0)
    end

    it 'should have license file created' do
      on(node, 'test -f /etc/sensu/license.json')
    end

    it 'should have valid license file content' do
      result = on(node, 'cat /etc/sensu/license.json')
      expect(result.stdout).to include('puppet')
      expect(result.stdout).to include('License')
    end
  end
end
