require 'spec_helper_acceptance'

describe 'sensu_namespace', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<~EOS
class { 'sensu':
  use_ssl           => true,
  ssl_ca_source     => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source   => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source    => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
}
include sensu::cli
sensu_namespace { 'test': ensure => 'present' }
sensu_namespace { 'test-api': ensure => 'present', provider => 'sensu_api' }
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

    it 'should have a valid namespace' do
      on node, 'sensuctl namespace list --format json' do |result|
        data = JSON.parse(result.stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d[0]['name']).to eq('test')
      end
    end

    it 'should have a valid namespace using API' do
      on node, 'sensuctl namespace list --format json' do |result|
        data = JSON.parse(result.stdout)
        d = data.select { |o| o['name'] == 'test-api' }
        expect(d[0]['name']).to eq('test-api')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<~EOS
class { 'sensu':
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
    class { 'sensu::backend':
ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
    }
include sensu::cli
sensu_namespace { 'test': ensure => 'absent' }
sensu_namespace { 'test-api': ensure => 'absent', provider => 'sensu_api' }
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

    it 'should not have test namespace' do
      on node, 'sensuctl namespace list --format json' do |result|
        data = JSON.parse(result.stdout)
        d = data.select { |o| o['name'] == 'test' }
        expect(d.size).to eq(0)
      end
    end

    it 'should not have test namespace using API' do
      on node, 'sensuctl namespace list --format json' do |result|
        data = JSON.parse(result.stdout)
        d = data.select { |o| o['name'] == 'test-api' }
        expect(d.size).to eq(0)
      end
    end
  end
end

