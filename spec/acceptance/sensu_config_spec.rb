require 'spec_helper_acceptance'

describe 'sensu_config', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'with updates' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_config { 'format':
        value => 'json',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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

    it 'should have a valid config' do
      on node, 'sensuctl config view --format json' do
        data = JSON.parse(stdout)
        expect(data['format']).to eq('json')
      end
    end
  end

  context 'ensure => absent' do
    it 'should result in error as unsupported' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_config { 'format': ensure => 'absent' }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [1,4,6]
      else
        apply_manifest_on(node, pp, :expect_failures => true)
      end
    end
  end
end

