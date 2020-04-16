require 'spec_helper_acceptance'

describe 'sensu RBAC resources', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_cluster_role { 'test':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      sensu_cluster_role { 'test-api':
        rules    => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
        provider => 'sensu_api',
      }
      sensu_role { 'test':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      sensu_role { 'test-api':
        rules    => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
        provider => 'sensu_api',
      }
      sensu_cluster_role_binding { 'test':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
      }
      sensu_cluster_role_binding { 'test2':
        role_ref => {'type' => 'Role', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
      }
      sensu_cluster_role_binding { 'test-api':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
        provider => 'sensu_api',
      }
      sensu_cluster_role_binding { 'test-api2':
        role_ref => {'type' => 'Role', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
        provider => 'sensu_api',
      }
      sensu_role_binding { 'test':
        role_ref => {'type' => 'Role', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
      }
      sensu_role_binding { 'test2':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
      }
      sensu_role_binding { 'test-api':
        role_ref => {'type' => 'Role', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
        provider => 'sensu_api',
      }
      sensu_role_binding { 'test-api2':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
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

    it 'should have a valid cluster_role' do
      on node, 'sensuctl cluster-role info test --format json' do
        data = JSON.parse(stdout)
        expect(data['rules']).to eq([{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => nil}])
      end
    end

    it 'should have a valid cluster_role from API' do
      on node, 'sensuctl cluster-role info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['rules']).to eq([{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => nil}])
      end
    end

    it 'should have a valid role' do
      on node, 'sensuctl role info test --format json' do
        data = JSON.parse(stdout)
        expect(data['rules']).to eq([{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => nil}])
      end
    end

    it 'should have a valid role using API' do
      on node, 'sensuctl role info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['rules']).to eq([{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => nil}])
      end
    end

    it 'should have a valid cluster_role_binding' do
      on node, 'sensuctl cluster-role-binding info test --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid cluster_role_binding with Role' do
      on node, 'sensuctl cluster-role-binding info test2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid cluster_role_binding using API' do
      on node, 'sensuctl cluster-role-binding info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid cluster_role_binding with Role using API' do
      on node, 'sensuctl cluster-role-binding info test-api2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid role_binding' do
      on node, 'sensuctl role-binding info test --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid role_binding for ClusterRole' do
      on node, 'sensuctl role-binding info test2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid role_binding using API' do
      on node, 'sensuctl role-binding info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid role_binding for ClusterRole using API' do
      on node, 'sensuctl role-binding info test-api2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end
  end

  context 'update cluster_role_binding' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_cluster_role { 'test':
        rules => [
          {'verbs' => ['get','list'], 'resources' => ['*'], resource_names => ['foo']},
          {'verbs' => ['get','list'], 'resources' => ['checks'], resource_names => ['bar']},
        ],
      }
      sensu_cluster_role { 'test-api':
        rules    => [
          {'verbs' => ['get','list'], 'resources' => ['*'], resource_names => ['foo']},
          {'verbs' => ['get','list'], 'resources' => ['checks'], resource_names => ['bar']},
        ],
        provider => 'sensu_api',
      }
      sensu_role { 'test':
        rules => [
          {'verbs' => ['get','list'], 'resources' => ['*'], resource_names => ['foo']},
          {'verbs' => ['get','list'], 'resources' => ['checks'], resource_names => ['bar']},
        ],
      }
      sensu_role { 'test-api':
        rules => [
          {'verbs' => ['get','list'], 'resources' => ['*'], resource_names => ['foo']},
          {'verbs' => ['get','list'], 'resources' => ['checks'], resource_names => ['bar']},
        ],
        provider => 'sensu_api',
      }
      sensu_role { 'test2':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      sensu_cluster_role { 'test2':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      sensu_cluster_role_binding { 'test':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}],
      }
      sensu_cluster_role_binding { 'test2':
        role_ref => {'type' => 'Role', 'name' => 'test2'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
      }
      sensu_cluster_role_binding { 'test-api':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test'},
        subjects => [{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}],
        provider => 'sensu_api',
      }
      sensu_cluster_role_binding { 'test-api2':
        role_ref => {'type' => 'Role', 'name' => 'test2'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
        provider => 'sensu_api',
      }
      sensu_role_binding { 'test':
        role_ref => {'type' => 'Role', 'name' => 'test2'},
        subjects => [{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}],
      }
      sensu_role_binding { 'test2':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test2'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
      }
      sensu_role_binding { 'test-api':
        role_ref => {'type' => 'Role', 'name' => 'test2'},
        subjects => [{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}],
        provider => 'sensu_api',
      }
      sensu_role_binding { 'test-api2':
        role_ref => {'type' => 'ClusterRole', 'name' => 'test2'},
        subjects => [{'type' => 'User', 'name' => 'admin'}],
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

    it 'should have a valid cluster_role with updated propery' do
      on node, 'sensuctl cluster-role info test --format json' do
        data = JSON.parse(stdout)
        expect(data['rules'].size).to eq(2)
        expect(data['rules'][0]).to eq({'verbs' => ['get','list'], 'resources' => ['*'], 'resource_names' => ['foo']})
        expect(data['rules'][1]).to eq({'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['bar']})
      end
    end

    it 'should have a valid cluster_role with updated propery using API' do
      on node, 'sensuctl cluster-role info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['rules'].size).to eq(2)
        expect(data['rules'][0]).to eq({'verbs' => ['get','list'], 'resources' => ['*'], 'resource_names' => ['foo']})
        expect(data['rules'][1]).to eq({'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['bar']})
      end
    end

    it 'should have a valid role with updated propery' do
      on node, 'sensuctl role info test --format json' do
        data = JSON.parse(stdout)
        expect(data['rules'].size).to eq(2)
        expect(data['rules'][0]).to eq({'verbs' => ['get','list'], 'resources' => ['*'], 'resource_names' => ['foo']})
        expect(data['rules'][1]).to eq({'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['bar']})
      end
    end

    it 'should have a valid role with updated propery using API' do
      on node, 'sensuctl role info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['rules'].size).to eq(2)
        expect(data['rules'][0]).to eq({'verbs' => ['get','list'], 'resources' => ['*'], 'resource_names' => ['foo']})
        expect(data['rules'][1]).to eq({'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['bar']})
      end
    end

    it 'should have a valid cluster_role_binding with updated propery' do
      on node, 'sensuctl cluster-role-binding info test --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}])
      end
    end

    it 'should have a valid cluster_role_binding with Role with updated property' do
      on node, 'sensuctl cluster-role-binding info test2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test2'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid cluster_role_binding with updated propery using API' do
      on node, 'sensuctl cluster-role-binding info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}])
      end
    end

    it 'should have a valid cluster_role_binding with Role with updated property using API' do
      on node, 'sensuctl cluster-role-binding info test-api2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test2'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid role_binding with updated propery' do
      on node, 'sensuctl role-binding info test --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test2'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}])
      end
    end

    it 'should have a valid role_binding for ClusterRole with updated property' do
      on node, 'sensuctl role-binding info test2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test2'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end

    it 'should have a valid role_binding with updated propery using API' do
      on node, 'sensuctl role-binding info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'Role', 'name' => 'test2'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'},{'type' => 'User', 'name' => 'agent'}])
      end
    end

    it 'should have a valid role_binding for ClusterRole with updated property using API' do
      on node, 'sensuctl role-binding info test-api2 --format json' do
        data = JSON.parse(stdout)
        expect(data['role_ref']).to eq({'type' => 'ClusterRole', 'name' => 'test2'})
        expect(data['subjects']).to eq([{'type' => 'User', 'name' => 'admin'}])
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_cluster_role { 'test': ensure => 'absent' }
      sensu_cluster_role { 'test-api':
        ensure   => 'absent',
        provider => 'sensu_api',
      }
      sensu_role { 'test': ensure => 'absent' }
      sensu_role { 'test-api': ensure => 'absent', provider => 'sensu_api' }
      sensu_cluster_role_binding { 'test': ensure => 'absent' }
      sensu_cluster_role_binding { 'test-api':
        ensure   => 'absent',
        provider => 'sensu_api',
      }
      sensu_role_binding { 'test': ensure => 'absent' }
      sensu_role_binding { 'test-api': ensure => 'absent', provider => 'sensu_api' }
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

    describe command('sensuctl cluster-role info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl cluster-role info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl role info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl role info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl cluster-role-binding info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl cluster-role-binding info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl role-binding info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl role-binding info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end

  context 'resource purging' do
    it 'should purge without errors' do
      before_pp = <<-EOS
      include sensu::backend
      sensu_cluster_role { 'test1':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      EOS
      pp = <<-EOS
      include ::sensu::backend
      sensu_resources { 'sensu_cluster_role':
        purge => true
      }
      sensu_cluster_role { 'test2':
        rules => [{'verbs' => ['get','list'], 'resources' => ['checks']}],
      }
      EOS

      apply_manifest_on(node, before_pp, :catch_failures => true)
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

    describe command('sensuctl cluster-role info test1'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl cluster-role info test2'), :node => node do
      its(:exit_status) { should eq 0 }
    end
  end
end
