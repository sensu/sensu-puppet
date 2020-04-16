require 'spec_helper_acceptance'

describe 'sensu_command', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'install command' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_command { 'command-test':
        ensure => 'present',
        url    => 'https://github.com/amdprophet/command-test/releases/download/v0.0.3/command-test_0.0.3_linux_amd64.tar.gz',
        sha512 => '29b0eae7795dfaa93da7ca1ae90f8a91ab52b6b98a3709bfca282c673afb67810981f35ade4d3b219752bcf83d6a42fc4739c62e7bac01aa0047dd8fa2341934',
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
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe command('sensuctl command exec command-test'), :node => node do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /hello world/ }
    end
  end

  context 'upgrade command' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_command { 'command-test':
        ensure => 'present',
        url    => 'https://github.com/amdprophet/command-test/releases/download/v0.0.4/command-test_0.0.4_linux_amd64.tar.gz',
        sha512 => '67aeba3652def271b1921bc1b4621354ad254c89946ebc8d1e39327f69a902d91f4b0326c9020a4a03e4cfbb718b454b6180f9c39aaff1e60daf6310be66244f',
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
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe command('sensuctl command exec command-test'), :node => node do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /hello world/ }
    end
  end

  context 'remove command' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_command { 'command-test':
        ensure => 'absent',
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
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe command('sensuctl command exec command-test'), :node => node do
      its(:exit_status) { should_not eq 0 }
      its(:stdout) { should_not match /hello world/ }
    end
  end
end
