require 'spec_helper_acceptance'

describe 'sensu::backend cluster class', if: RSpec.configuration.sensu_cluster do
  node1 = hosts_with_name(hosts, 'sensu_backend1')[0]
  node2 = hosts_with_name(hosts, 'sensu_backend2')[0]
  node3 = hosts_with_name(hosts, 'sensu_backend3')[0]
  context 'new cluster' do
    it 'should work without errors' do
      node1_pp = <<-EOS
      class { '::sensu::backend':
        config_hash => {
          'etcd-advertise-client-urls'       => 'http://#{fact_on(node1, 'ipaddress')}:2379',
          'etcd-listen-client-urls'          => 'http://#{fact_on(node1, 'ipaddress')}:2379',
          'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
          'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380',
          'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node1, 'ipaddress')}:2380',
          'etcd-initial-cluster-state'       => 'new',
          'etcd-initial-cluster-token'       => '',
          'etcd-name'                        => 'backend1',
        },
      }
      EOS
      node2_pp = <<-EOS
      class { '::sensu::backend':
        config_hash => {
          'etcd-advertise-client-urls'       => 'http://#{fact_on(node2, 'ipaddress')}:2379',
          'etcd-listen-client-urls'          => 'http://#{fact_on(node2, 'ipaddress')}:2379',
          'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
          'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380',
          'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node2, 'ipaddress')}:2380',
          'etcd-initial-cluster-state'       => 'new',
          'etcd-initial-cluster-token'       => '',
          'etcd-name'                        => 'backend2',
        },
      }
      EOS

      apply_manifest_on(node1, node1_pp, :catch_failures => true)
      #on node1, 'curl http://127.0.0.1:8080/info', :accept_all_exit_codes => true
      apply_manifest_on(node2, node2_pp, :catch_failures => true)
      # first node has to have agent started back up
      #on node1, 'systemctl status sensu-agent -l', :accept_all_exit_codes => true
      #on node1, 'curl http://127.0.0.1:8080/info', :accept_all_exit_codes => true
      apply_manifest_on(node1, node1_pp, :catch_failures => true)
      apply_manifest_on(node1, node1_pp, :catch_changes  => true)
      apply_manifest_on(node2, node2_pp, :catch_changes  => true)
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
      on node1, 'sensuctl cluster member-list --format json' do
        data = JSON.parse(stdout)
        expect(data['members'].size).to eq(2)
      end
    end

    it 'should be healthy' do
      on node1, 'sensuctl cluster health --format json' do
        data = JSON.parse(stdout)
        healthy = data.select { |m| m['Healthy'] == true }
        expect(healthy.size).to eq(2)
      end
    end
  end

  context 'Add sensu backend cluster member' do
    it 'should add member' do
      pp = <<-EOS
      sensu_cluster_member { 'backend3':
        peer_urls => ['http://#{fact_on(node3, 'ipaddress')}:2380'],
      }
      EOS
      node3_pp = <<-EOS
      class { '::sensu::backend':
        config_hash => {
          'etcd-advertise-client-urls'       => 'http://#{fact_on(node3, 'ipaddress')}:2379',
          'etcd-listen-client-urls'          => 'http://#{fact_on(node3, 'ipaddress')}:2379',
          'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
          'etcd-initial-cluster'             => 'backend1=http://#{fact_on(node1, 'ipaddress')}:2380,backend2=http://#{fact_on(node2, 'ipaddress')}:2380,backend3=http://#{fact_on(node3, 'ipaddress')}:2380',
          'etcd-initial-advertise-peer-urls' => 'http://#{fact_on(node3, 'ipaddress')}:2380',
          'etcd-initial-cluster-state'       => 'existing',
          'etcd-initial-cluster-token'       => '',
          'etcd-name'                        => 'backend3',
        },
      }
      EOS

      apply_manifest_on(node1, pp, :catch_failures => true)
      apply_manifest_on(node3, node3_pp, :catch_failures => true)
      apply_manifest_on(node1, pp, :catch_changes  => true)
      apply_manifest_on(node3, node3_pp, :catch_changes  => true)
    end

    describe service('sensu-backend'), :node => node3 do
      it { should be_enabled }
      it { should be_running }
    end

    it 'should have new cluster member' do
      on node1, 'sensuctl cluster member-list --format json' do
        data = JSON.parse(stdout)
        member = data['members'].select { |m| m['name'] == 'backend3' }[0]
        expect(member['peerURLs']).to eq(["http://#{fact_on(node3, 'ipaddress')}:2380"])
      end
    end

    it 'should be healthy' do
      on node1, 'sensuctl cluster health --format json' do
        data = JSON.parse(stdout)
        healthy = data.select { |m| m['Healthy'] == true }
        expect(healthy.size).to eq(3)
      end
    end
  end
end
