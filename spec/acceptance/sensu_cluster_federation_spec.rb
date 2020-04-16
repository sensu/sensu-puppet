require 'spec_helper_acceptance'

describe 'sensu_cluster_federation', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_cluster_federation { 'test':
        api_urls => ['https://#{fact_on(node, 'ipaddress')}:8080'],
      }
      sensu_cluster_federation { 'testapi':
        api_urls => ['https://#{fact_on(node, 'ipaddress')}:8080'],
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

    it 'should have a valid federated cluster' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'test' }
        expect(data['metadata']['name']).to eq('test')
        expect(data['spec']['api_urls']).to eq(["https://#{fact_on(node, 'ipaddress')}:8080"])
      end
    end

    it 'should have a valid federated cluster using API' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'testapi' }
        expect(data['metadata']['name']).to eq('testapi')
        expect(data['spec']['api_urls']).to eq(["https://#{fact_on(node, 'ipaddress')}:8080"])
      end
    end
  end

  context 'updates' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_cluster_federation { 'test':
        api_urls => ['https://#{fact_on(node, 'ipaddress')}:9080'],
      }
      sensu_cluster_federation { 'testapi':
        api_urls => ['https://#{fact_on(node, 'ipaddress')}:9080'],
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

    it 'should have updated a federated cluster' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'test' }
        expect(data['metadata']['name']).to eq('test')
        expect(data['spec']['api_urls']).to eq(["https://#{fact_on(node, 'ipaddress')}:9080"])
      end
    end

    it 'should have updated a federated cluster using API' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'testapi' }
        expect(data['metadata']['name']).to eq('testapi')
        expect(data['spec']['api_urls']).to eq(["https://#{fact_on(node, 'ipaddress')}:9080"])
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_cluster_federation { 'test': ensure => 'absent' }
      sensu_cluster_federation { 'testapi': ensure => 'absent', provider => 'sensu_api' }
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

    it 'should have removed a federated clusters' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.Cluster --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        expect(resources.size).to eq(0)
      end
    end
  end
end
