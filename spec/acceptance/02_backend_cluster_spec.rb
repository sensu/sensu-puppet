require 'spec_helper_acceptance'

describe 'sensu::backend cluster class', if: RSpec.configuration.sensu_mode == 'cluster' do
  node1 = hosts_with_name(hosts, 'sensu-backend1')[0] || hosts_with_name(hosts, 'sensu-backend-1')[0]
  node2 = hosts_with_name(hosts, 'sensu-backend2')[0] || hosts_with_name(hosts, 'sensu-backend-2')[0]
  node3 = hosts_with_name(hosts, 'sensu-backend3')[0] || hosts_with_name(hosts, 'sensu-backend-3')[0]
  
  before(:all) do
    # Generate SSL certificates with correct IPs for all cluster nodes
    puts "=== Setting up SSL certificates for cluster nodes ==="
    
    node1_ip = fact_on(node1, 'ipaddress')
    node2_ip = fact_on(node2, 'ipaddress')
    node3_ip = fact_on(node3, 'ipaddress')
    
    puts "Node IPs: #{node1_ip}, #{node2_ip}, #{node3_ip}"
    
    # Copy certificate generation script to local system
    script_path = File.expand_path('../../generate_cluster_ssl_certs.sh', File.dirname(__FILE__))
    
    # Generate certificates on local system with all node IPs
    result = system("bash #{script_path} #{node1_ip} #{node2_ip} #{node3_ip}")
    unless result
      raise "Failed to generate SSL certificates"
    end
    
    cert_dir = '/tmp/sensu_cluster_certs'
    
    # Copy certificates to all nodes
    [node1, node2, node3].each do |node|
      puts "Copying certificates to #{node}"
      
      # Create certificate directories on the node
      on node, 'mkdir -p /etc/puppetlabs/puppet/ssl/ca'
      on node, 'mkdir -p /etc/puppetlabs/puppet/ssl/certs'
      on node, 'mkdir -p /etc/puppetlabs/puppet/ssl/private_keys'
      
      # Copy certificates to the node
      scp_to(node, "#{cert_dir}/ca.pem", '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem')
      scp_to(node, "#{cert_dir}/backend-cert.pem", '/etc/puppetlabs/puppet/ssl/certs/cert.pem')
      scp_to(node, "#{cert_dir}/backend-key.pem", '/etc/puppetlabs/puppet/ssl/private_keys/key.pem')
      
      # Set proper permissions
      on node, 'chmod 644 /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem'
      on node, 'chmod 644 /etc/puppetlabs/puppet/ssl/certs/cert.pem'
      on node, 'chmod 600 /etc/puppetlabs/puppet/ssl/private_keys/key.pem'
    end
    
    puts "=== SSL certificates setup complete ==="
  end
  
  context 'new cluster' do
    it 'should work without errors' do
      node1_pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node1, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  config_hash => {
    'etcd-advertise-client-urls'       => 'http://#{fact_on(node1, 'ipaddress')}:2379',
    'etcd-listen-client-urls'          => 'http://0.0.0.0:2379',
    'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
    'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380',
    'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node1, 'ipaddress')}:2380',
    'etcd-initial-cluster-state'       => 'new',
    'etcd-initial-cluster-token'       => '',
    'etcd-name'                        => 'backend1',
  },
}
      EOS
      node2_pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node2, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  config_hash => {
    'etcd-advertise-client-urls'       => 'http://#{fact_on(node2, 'ipaddress')}:2379',
    'etcd-listen-client-urls'          => 'http://0.0.0.0:2379',
    'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
    'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380',
    'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node2, 'ipaddress')}:2380',
    'etcd-initial-cluster-state'       => 'new',
    'etcd-initial-cluster-token'       => '',
    'etcd-name'                        => 'backend2',
  },
}
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<~EOS
  node 'sensu-backend1' { #{node1_pp} }
  node 'sensu-backend2' { #{node2_pp} }
        EOS
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        # First run will fail to run sensuctl configure
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,1,4,6]
        on node2, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        # first node has to have agent started back up
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
        on node2, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # First run will fail to run sensuctl configure
        apply_manifest_on(node1, node1_pp, :acceptable_exit_codes => [0,1])
        apply_manifest_on(node2, node2_pp, :catch_failures => true)
        # first node has to have agent started back up
        apply_manifest_on(node1, node1_pp, :catch_failures => true)
        apply_manifest_on(node1, node1_pp, :catch_changes  => true)
        apply_manifest_on(node2, node2_pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node1 do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('sensu-backend'), :node => node2 do
      it { should be_enabled }
      it { should be_running }
    end
    it 'should have cluster members' do
      on node1, 'sensuctl cluster member-list --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['members'].size).to eq(2)
      end
    end

    it 'should be healthy' do
      on node1, 'sensuctl cluster health --format json' do |result|
        data = JSON.parse(result.stdout)
        healthy = data.select { |m| m['Healthy'] == true }
        expect(healthy.size).to eq(2)
      end
    end
  end

  context 'Add sensu backend cluster member' do
    it 'should add member' do
      pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node1, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
include sensu::api
sensu_cluster_member { 'backend3':
  peer_urls => ['http://#{fact_on(node3, 'ipaddress')}:2380'],
}
      EOS
      node3_pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node3, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',}
class { '::sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  config_hash => {
    'etcd-advertise-client-urls'       => 'http://#{fact_on(node3, 'ipaddress')}:2379',
    'etcd-listen-client-urls'          => 'http://0.0.0.0:2379',
    'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
    'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380,backend3=http://#{fact_on(node3, 'ipaddress')}:2380',
    'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node3, 'ipaddress')}:2380',
    'etcd-initial-cluster-state'       => 'existing',
    'etcd-initial-cluster-token'       => '',
    'etcd-name'                        => 'backend3',
  },
}
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<~EOS
  node 'sensu-backend1' { #{pp} }
  node 'sensu-backend3' { #{node3_pp} }
        EOS
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node3, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
        on node3, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(node1, pp, :catch_failures => true)
        apply_manifest_on(node3, node3_pp, :catch_failures => true)
        apply_manifest_on(node1, pp, :catch_changes  => true)
        apply_manifest_on(node3, node3_pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node3 do
      it { should be_enabled }
      it { should be_running }
    end

    it 'should have new cluster member' do
      on node1, 'sensuctl cluster member-list --format json' do |result|
        data = JSON.parse(result.stdout)
        member = data['members'].select { |m| m['name'] == 'backend3' }[0]
        expect(member['peerURLs']).to eq(["http://#{fact_on(node3, 'ipaddress')}:2380"])
      end
    end

    it 'should be healthy' do
      on node1, 'sensuctl cluster health --format json' do |result|
        data = JSON.parse(result.stdout)
        healthy = data.select { |m| m['Healthy'] == true }
        expect(healthy.size).to eq(3)
      end
    end
  end

  context 'new cluster' do
    it 'should work without errors' do
      node1_pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node1, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',}
class { '::sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  config_hash => {
    'etcd-advertise-client-urls'       => 'http://#{fact_on(node1, 'ipaddress')}:2379',
    'etcd-listen-client-urls'          => 'http://0.0.0.0:2379',
    'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
    'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380',
    'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node1, 'ipaddress')}:2380',
    'etcd-initial-cluster-state'       => 'new',
    'etcd-initial-cluster-token'       => '',
    'etcd-name'                        => 'backend1',
  },
}
      EOS
      node2_pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node2, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',}
class { '::sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  config_hash => {
    'etcd-advertise-client-urls'       => 'http://#{fact_on(node2, 'ipaddress')}:2379',
    'etcd-listen-client-urls'          => 'http://0.0.0.0:2379',
    'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
    'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380',
    'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node2, 'ipaddress')}:2380',
    'etcd-initial-cluster-state'       => 'new',
    'etcd-initial-cluster-token'       => '',
    'etcd-name'                        => 'backend2',
  },
}
      EOS

      # cleanup previous tests
      backend_nodes = [node1, node2, node3]
      on backend_nodes, 'systemctl stop sensu-backend', :acceptable_exit_codes => [0,5]
      on backend_nodes, 'rm -rf /var/lib/sensu/sensu-backend/etcd/*'
      on backend_nodes, 'rm -rf /root/.config'
      on backend_nodes, 'puppet resource package sensu-go-backend ensure=absent'

      if RSpec.configuration.sensu_use_agent
        site_pp = <<~EOS
  node 'sensu-backend1' { #{node1_pp} }
  node 'sensu-backend2' { #{node2_pp} }
        EOS
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        # First run will fail to run sensuctl configure
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,1,4,6]
        on node2, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        # first node has to have agent started back up
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
        on node2, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # First run will fail to run sensuctl configure
        apply_manifest_on(node1, node1_pp, :acceptable_exit_codes => [0,1])
        apply_manifest_on(node2, node2_pp, :catch_failures => true)
        # first node has to have agent started back up
        apply_manifest_on(node1, node1_pp, :catch_failures => true)
        apply_manifest_on(node1, node1_pp, :catch_changes  => true)
        apply_manifest_on(node2, node2_pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node1 do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('sensu-backend'), :node => node2 do
      it { should be_enabled }
      it { should be_running }
    end
    it 'should have cluster members' do
      on node1, 'sensuctl cluster member-list --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['members'].size).to eq(2)
      end
    end

    it 'should be healthy' do
      on node1, 'sensuctl cluster health --format json' do |result|
        data = JSON.parse(result.stdout)
        healthy = data.select { |m| m['Healthy'] == true }
        expect(healthy.size).to eq(2)
      end
    end
  end

  context 'Add sensu backend cluster member' do
    it 'should add member' do
      pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node1, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
include sensu::api
sensu_cluster_member { 'backend3':
  peer_urls => ['http://#{fact_on(node3, 'ipaddress')}:2380'],
  provider  => 'sensu_api',
}
      EOS
      node3_pp = <<~EOS
class { 'sensu':
  password => 'P@ssw0rd!',
  api_host => '#{fact_on(node3, 'ipaddress')}',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  config_hash => {
    'etcd-advertise-client-urls'       => 'http://#{fact_on(node3, 'ipaddress')}:2379',
    'etcd-listen-client-urls'          => 'http://0.0.0.0:2379',
    'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
    'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380,backend3=http://#{fact_on(node3, 'ipaddress')}:2380',
    'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node3, 'ipaddress')}:2380',
    'etcd-initial-cluster-state'       => 'existing',
    'etcd-initial-cluster-token'       => '',
    'etcd-name'                        => 'backend3',
  },
}
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = <<~EOS
  node 'sensu-backend1' { #{pp} }
  node 'sensu-backend3' { #{node3_pp} }
        EOS
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node3, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node1, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
        on node3, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(node1, pp, :catch_failures => true)
        apply_manifest_on(node3, node3_pp, :catch_failures => true)
        apply_manifest_on(node1, pp, :catch_changes  => true)
        apply_manifest_on(node3, node3_pp, :catch_changes  => true)
      end
    end

    describe service('sensu-backend'), :node => node3 do
      it { should be_enabled }
      it { should be_running }
    end

    it 'should have new cluster member' do
      on node1, 'sensuctl cluster member-list --format json' do |result|
        data = JSON.parse(result.stdout)
        member = data['members'].select { |m| m['name'] == 'backend3' }[0]
        expect(member['peerURLs']).to eq(["http://#{fact_on(node3, 'ipaddress')}:2380"])
      end
    end

    it 'should be healthy' do
      on node1, 'sensuctl cluster health --format json' do |result|
        data = JSON.parse(result.stdout)
        healthy = data.select { |m| m['Healthy'] == true }
        expect(healthy.size).to eq(3)
      end
    end
  end
end
