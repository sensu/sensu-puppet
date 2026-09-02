require 'spec_helper_acceptance'

describe 'sensu_command', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'install command' do
    it 'should work without errors' do
      arch = on(node, 'uname -m').stdout.strip == 'aarch64' ? 'arm64' : 'amd64'
      url    = "https://github.com/amdprophet/command-test/releases/download/v0.0.3/command-test_0.0.3_linux_#{arch}.tar.gz"
      sha512 = arch == 'arm64' \
        ? '876ade1a9d3308b0f573576260bfabf5e233ec3cf14c85e3ef61cda9ac18dd739ff4b296e837bc45ab0e48a23c01e911a2f068f0eb94490b66aa7a4aa6c134b0' \
        : '29b0eae7795dfaa93da7ca1ae90f8a91ab52b6b98a3709bfca282c673afb67810981f35ade4d3b219752bcf83d6a42fc4739c62e7bac01aa0047dd8fa2341934'
      pp = <<-EOS
      include sensu::backend
      sensu_command { 'command-test':
        ensure => 'present',
        url    => '#{url}',
        sha512 => '#{sha512}',
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
      arch = on(node, 'uname -m').stdout.strip == 'aarch64' ? 'arm64' : 'amd64'
      url    = "https://github.com/amdprophet/command-test/releases/download/v0.0.4/command-test_0.0.4_linux_#{arch}.tar.gz"
      sha512 = arch == 'arm64' \
        ? '1b93f3bb5289d773cb2495c39691a5c2a5e4b35d909be1cafb893e0e8497a25f370571aa5f15b31be43b078f49e55ac42fd49f8d8a591958b942cc8c0a81a052' \
        : '67aeba3652def271b1921bc1b4621354ad254c89946ebc8d1e39327f69a902d91f4b0326c9020a4a03e4cfbb718b454b6180f9c39aaff1e60daf6310be66244f'
      pp = <<-EOS
      include sensu::backend
      sensu_command { 'command-test':
        ensure => 'present',
        url    => '#{url}',
        sha512 => '#{sha512}',
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
