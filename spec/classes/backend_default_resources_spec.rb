require 'spec_helper'

describe 'sensu::backend::default_resources', :type => :class do
  on_supported_os({
    supported_os: [{ 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['7'] }]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        it { should compile.with_all_deps }
        it { should have_sensu_namespace_resource_count(1) }
        it { should contain_sensu_namespace('default').with_ensure('present') }
        it { should have_sensu_cluster_role_resource_count(7) }
        it {
          should contain_sensu_cluster_role('admin').with({
            'ensure' => 'present',
            'rules'  => [
              {
                'verbs'     => ['*'],
                'resources' => [
                  'assets',
                  'checks',
                  'entities',
                  'extensions',
                  'events',
                  'filters',
                  'handlers',
                  'hooks',
                  'mutators',
                  'silenced',
                  'roles',
                  'rolebindings',
                ],
                'resource_names' => nil,
              },
              {
                'verbs'     => ['get', 'list'],
                'resources' => ['namespaces'],
                'resource_names' => nil,
              },
            ],
          })
        }
        it {
          should contain_sensu_cluster_role('cluster-admin').with({
            'ensure' => 'present',
            'rules'  => [
              {
                'verbs'     => ['*'],
                'resources' => ['*'],
                'resource_names' => nil,
              },
            ],
          })
        }
        it {
          should contain_sensu_cluster_role('edit').with({
            'ensure' => 'present',
            'rules'  => [
              {
                'verbs'     => ['*'],
                'resources' => [
                  'assets',
                  'checks',
                  'entities',
                  'extensions',
                  'events',
                  'filters',
                  'handlers',
                  'hooks',
                  'mutators',
                  'silenced',
                ],
                'resource_names' => nil,
              },
              {
                'verbs'     => ['get', 'list'],
                'resources' => ['namespaces'],
                'resource_names' => nil,
              },
            ],
          })
        }
        it {
          should contain_sensu_cluster_role('system:agent').with({
            'ensure' => 'present',
            'rules'  => [
              {
                'verbs'     => ['*'],
                'resources' => ['events'],
                'resource_names' => nil,
              },
            ],
          })
        }
        it {
          should contain_sensu_cluster_role('system:user').with({
            'ensure' => 'present',
            'rules'  => [
              {
                'verbs'     => ['get', 'update'],
                'resources' => ['localselfuser'],
                'resource_names' => nil,
              },
            ],
          })
        }
        it {
          should contain_sensu_cluster_role('view').with({
            'ensure' => 'present',
            'rules'  => [
              {
                'verbs'     => ['get', 'list'],
                'resources' => [
                  'assets',
                  'checks',
                  'entities',
                  'extensions',
                  'events',
                  'filters',
                  'handlers',
                  'hooks',
                  'mutators',
                  'silenced',
                  'namespaces',
                ],
                'resource_names' => nil,
              },
            ],
          })
        }
        it { should have_sensu_cluster_role_binding_resource_count(4) }
        it {
          should contain_sensu_cluster_role_binding('cluster-admin').with({
            'ensure'   => 'present',
            'role_ref' => {'type' => 'ClusterRole', 'name' => 'cluster-admin'},
            'subjects' => [
              {
                'type' => 'Group',
                'name' => 'cluster-admins'
              },
            ],
          })
        }
        it {
          should contain_sensu_cluster_role_binding('system:agent').with({
            'ensure'   => 'present',
            'role_ref' => {'type' => 'ClusterRole', 'name' => 'system:agent'},
            'subjects' => [
              {
                'type' => 'Group',
                'name' => 'system:agents'
              },
            ],
          })
        }
        it {
          should contain_sensu_cluster_role_binding('system:user').with({
            'ensure'   => 'present',
            'role_ref' => {'type' => 'ClusterRole', 'name' => 'system:user'},
            'subjects' => [
              {
                'type' => 'Group',
                'name' => 'system:users'
              },
            ],
          })
        }
      end
    end
  end
end
