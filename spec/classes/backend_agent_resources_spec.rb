require 'spec_helper'

describe 'sensu::backend::default_resources', :type => :class do
  on_supported_os({
    supported_os: [{ 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['7'] }]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        it { should compile.with_all_deps }
        it {
          should contain_sensu_cluster_role('puppet:agent_entity_config').with({
            'ensure' => 'present',
            'rules'  => [
              {
                'verbs'     => ['*'],
                'resources' => [
                  'entities',
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
          should contain_sensu_cluster_role_binding('puppet:agent_entity_config').with({
            'ensure'   => 'present',
            'role_ref' => {'type' => 'ClusterRole', 'name' => 'puppet:agent_entity_config'},
            'subjects' => [
              {
                'type' => 'Group',
                'name' => 'puppet:agent_entity_config'
              },
            ],
          })
        }
        it {
          should contain_sensu_user('puppet-agent_entity_config').with({
            'ensure'    => 'present',
            'disabled'  => 'false',
            'groups'    => ['puppet:agent_entity_config'],
            'password'  => 'P@ssw0rd!',
          })
        }
      end
    end
  end
end
