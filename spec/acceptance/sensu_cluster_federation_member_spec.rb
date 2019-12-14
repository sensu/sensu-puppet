require 'spec_helper_acceptance'

describe 'sensu_cluster_federation', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_cluster_federation_member { 'https://#{fact_on(node, 'ipaddress')}:8080 in test':
        ensure => 'present',
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

    it 'should have a valid federated cluster' do
      # Force token refresh and get access token for API request
      token = nil
      on node, 'sensuctl namespace list 2>/dev/null 1>/dev/null ; cat ~/.config/sensu/sensuctl/cluster' do
        data = JSON.parse(stdout)
        token = data['access_token']
      end
      on node, "curl -k -H 'Authorization: Bearer #{token}' https://sensu_backend:8080/api/enterprise/federation/v1/clusters/test" do
        data = JSON.parse(stdout)
        expect(data['spec']['api_urls']).to include("https://#{fact_on(node, 'ipaddress')}:8080")
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_cluster_federation_member { 'https://#{fact_on(node, 'ipaddress')}:8080 in test':
        ensure => 'absent',
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

    it 'should have removed a federated cluster' do
      # Force token refresh and get access token for API request
      token = nil
      on node, 'sensuctl namespace list 2>/dev/null 1>/dev/null ; cat ~/.config/sensu/sensuctl/cluster' do
        data = JSON.parse(stdout)
        token = data['access_token']
      end
      on node, "curl -k -H 'Authorization: Bearer #{token}' https://sensu_backend:8080/api/enterprise/federation/v1/clusters/test" do
        data = JSON.parse(stdout)
        expect(data['spec']['api_urls']).not_to include("https://#{fact_on(node, 'ipaddress')}:8080")
      end
    end
  end
end
