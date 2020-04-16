require 'spec_helper_acceptance'

describe 'sensu_etcd_replicator', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_etcd_replicator { 'role_replicator':
        ensure        => 'present',
        ca_cert       => '/path/to/ssl/trusted-certificate-authorities.pem',
        cert          => '/path/to/ssl/cert.pem',
        key           => '/path/to/ssl/key.pem',
        url           => 'http://127.0.0.1:3379',
        resource_name => 'Role',
      }
      sensu_etcd_replicator { 'rolebinding_replicator':
        ensure        => 'present',
        ca_cert       => '/path/to/ssl/trusted-certificate-authorities.pem',
        cert          => '/path/to/ssl/cert.pem',
        key           => '/path/to/ssl/key.pem',
        url           => 'http://127.0.0.1:3379',
        resource_name => 'RoleBinding',
        provider      => 'sensu_api',
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

    it 'should have a valid etcd replicators' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.EtcdReplicator --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        role = resources.find { |r| r['metadata']['name'] == 'role_replicator' }
        rolebinding = resources.find { |r| r['metadata']['name'] == 'rolebinding_replicator' }
        expect(role['spec']['ca_cert']).to eq('/path/to/ssl/trusted-certificate-authorities.pem')
        expect(role['spec']['cert']).to eq('/path/to/ssl/cert.pem')
        expect(role['spec']['key']).to eq('/path/to/ssl/key.pem')
        expect(role['spec']['url']).to eq('http://127.0.0.1:3379')
        expect(role['spec']['resource']).to eq('Role')
        expect(role['spec']['replication_interval_seconds']).to eq(30)
        expect(role['spec']['api_version']).to eq('core/v2')
        expect(rolebinding['spec']['ca_cert']).to eq('/path/to/ssl/trusted-certificate-authorities.pem')
        expect(rolebinding['spec']['cert']).to eq('/path/to/ssl/cert.pem')
        expect(rolebinding['spec']['key']).to eq('/path/to/ssl/key.pem')
        expect(rolebinding['spec']['url']).to eq('http://127.0.0.1:3379')
        expect(rolebinding['spec']['resource']).to eq('RoleBinding')
        expect(rolebinding['spec']['replication_interval_seconds']).to eq(30)
        expect(rolebinding['spec']['api_version']).to eq('core/v2')
      end
    end
  end

  context 'updates' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_etcd_replicator { 'role_replicator':
        ensure                       => 'present',
        ca_cert                      => '/path/to/ssl/trusted-certificate-authorities2.pem',
        cert                         => '/path/to/ssl/cert2.pem',
        key                          => '/path/to/ssl/key2.pem',
        url                          => 'http://127.0.0.1:3379',
        resource_name                => 'Role',
        replication_interval_seconds => 60,
      }
      sensu_etcd_replicator { 'rolebinding_replicator':
        ensure                       => 'present',
        ca_cert                      => '/path/to/ssl/trusted-certificate-authorities2.pem',
        cert                         => '/path/to/ssl/cert2.pem',
        key                          => '/path/to/ssl/key2.pem',
        url                          => 'http://127.0.0.1:3379',
        resource_name                => 'RoleBinding',
        replication_interval_seconds => 60,
        provider                     => 'sensu_api',
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

    it 'should have a valid etcd replicators' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.EtcdReplicator --format yaml --all-namespaces' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        role = resources.find { |r| r['metadata']['name'] == 'role_replicator' }
        rolebinding = resources.find { |r| r['metadata']['name'] == 'rolebinding_replicator' }
        expect(role['spec']['ca_cert']).to eq('/path/to/ssl/trusted-certificate-authorities2.pem')
        expect(role['spec']['cert']).to eq('/path/to/ssl/cert2.pem')
        expect(role['spec']['key']).to eq('/path/to/ssl/key2.pem')
        expect(role['spec']['url']).to eq('http://127.0.0.1:3379')
        expect(role['spec']['resource']).to eq('Role')
        expect(role['spec']['replication_interval_seconds']).to eq(60)
        expect(role['spec']['api_version']).to eq('core/v2')
        expect(rolebinding['spec']['ca_cert']).to eq('/path/to/ssl/trusted-certificate-authorities2.pem')
        expect(rolebinding['spec']['cert']).to eq('/path/to/ssl/cert2.pem')
        expect(rolebinding['spec']['key']).to eq('/path/to/ssl/key2.pem')
        expect(rolebinding['spec']['url']).to eq('http://127.0.0.1:3379')
        expect(rolebinding['spec']['resource']).to eq('RoleBinding')
        expect(rolebinding['spec']['replication_interval_seconds']).to eq(60)
        expect(rolebinding['spec']['api_version']).to eq('core/v2')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_etcd_replicator { 'role_replicator': ensure => 'absent' }
      sensu_etcd_replicator { 'rolebinding_replicator':
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

    it 'removed etcd replicators' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump federation/v1.EtcdReplicator --format yaml --all-namespaces' do
        expect(stdout).to be_empty
      end
    end
  end
end
