require 'spec_helper_acceptance'

describe 'sensu_cluster_federation_member', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_cluster_federation_member { 'https://#{fact_on(node, 'ipaddress')}:8080 in test':
        ensure => 'present',
      }
      sensu_cluster_federation_member { 'https://#{fact_on(node, 'ipaddress')}:8080 in testapi':
        ensure   => 'present',
        provider => 'sensu_api',
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

    it 'should have a valid federated cluster member' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'test' }
        expect(data['spec']['api_urls']).to include("https://#{fact_on(node, 'ipaddress')}:8080")
      end
    end

    it 'should have a valid federated cluster member using API' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'testapi' }
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
      sensu_cluster_federation_member { 'https://#{fact_on(node, 'ipaddress')}:8080 in testapi':
        ensure   => 'absent',
        provider => 'sensu_api',
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

    it 'should have removed a federated cluster member' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'test' }
        expect(data['spec']['api_urls']).not_to include("https://#{fact_on(node, 'ipaddress')}:8080")
      end
    end

    it 'should have removed a federated cluster member using API' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'testapi' }
        expect(data['spec']['api_urls']).not_to include("https://#{fact_on(node, 'ipaddress')}:8080")
      end
    end
  end
end
