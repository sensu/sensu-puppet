require 'spec_helper'

describe 'sensu::resources', :type => :class do
  on_supported_os({
    supported_os: [{ 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['7'] }]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'ad_auths defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            ad_auths => {
              'ad' => {
                'servers'             => [{
                  'host'         => 'test', 'port' => 389,
                  'binding'      => {'user_dn' => 'cn=foo','password' => 'foo'},
                  'group_search' => {'base_dn' => 'ou=Groups'},
                  'user_search'  => {'base_dn' => 'ou=People'},
                }],
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_ad_auth('ad') }
      end
      context 'assets defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            assets => {
              'test' => {
                'builds' => [{
                  'url'    => 'http://localhost',
                  'sha512' => '0e3e75234abc68f4378a86b3f4b32a198ba301845b0cd6e50106e874345700cc6663a86c1ea125dc5e92be17c98f9a0f85ca9d5f595db2012f7cc3571945c123',
                }]
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_asset('test') }
      end
      context 'bonsai_assets defined' do
        let(:pre_condition) do
          <<-EOS
            class { 'sensu::resources':
              bonsai_assets => {
                'sensu/sensu-pagerduty-handler' => { 'ensure' => 'present' }
              }
            }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_bonsai_asset('sensu/sensu-pagerduty-handler') }
      end
      context 'checks defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            checks => {
              'test' => {
                'command' => 'foobar',
                'subscriptions' => ['demo'],
                'handlers' => ['slack'],
                'interval' => 60,
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_check('test') }
      end
      context 'cluster_federations defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::sensu::resources':
            cluster_federations => {
              'test' => {'api_urls' => ['http://10.0.0.1:8080'] },
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_cluster_federation('test') }
      end
      context 'cluster_federation_members defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::sensu::resources':
            cluster_federation_members => {
              'test' => {'api_url' => ['http://10.0.0.1:8080'], 'cluster' => 'test' },
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_cluster_federation_member('test') }
      end
      context 'cluster_members defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            cluster_members => {
              'test' => {
                'peer_urls' => ['http://localhost:2380'],
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_cluster_member('test') }
      end
      context 'cluster_role_bindings defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            cluster_role_bindings => {
              'test' => {
                'role_ref' => {'type' => 'ClusterRole', 'name' => 'test'},
                'subjects' => [{'type' => 'User', 'name' => 'test'}],
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_cluster_role_binding('test') }
      end
      context 'cluster_roles defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            cluster_roles => {
              'test'  => {
                'rules' => [{'verbs' => ['get','list'], 'resources' => ['checks']}]
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_cluster_role('test') }
      end
      context 'entities defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            entities => {
              'test' => {
                'entity_class' => 'proxy',
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_entity('test') }
      end
      context 'etcd_replicators defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            etcd_replicators => {
              'role_replicator' => {
                'ca_cert'                      => '/path/to/ssl/trusted-certificate-authorities.pem',
                'cert'                         => '/path/to/ssl/cert.pem',
                'key'                          => '/path/to/ssl/key.pem',
                'insecure'                     => false,
                'url'                          => 'http://127.0.0.1:3379',
                'api_version'                  => 'core/v2',
                'resource_name'                => 'Role',
                'replication_interval_seconds' => 30,
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_etcd_replicator('role_replicator') }
      end
      context 'filters defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            filters => {
              'test' => {
                'action'      => 'allow',
                'expressions' => ['event.Check.Occurrences == 1']
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_filter('test') }
      end
      context 'handlers defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            handlers => {
              'test' => {
                'type'        => 'pipe',
                'command'     => 'test',
                'socket'      => {'host' => '127.0.0.1', 'port' => 9000},
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_handler('test') }
      end
      context 'hooks defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            hooks => {
              'test' => { 'command' => 'test' },
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_hook('test') }
      end
      context 'ldap_auths defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            ldap_auths => {
              'ldap' => {
                'servers'             => [{
                  'host'         => 'test', 'port' => 389,
                  'binding'      => {'user_dn' => 'cn=foo','password' => 'foo'},
                  'group_search' => {'base_dn' => 'ou=Groups'},
                  'user_search'  => {'base_dn' => 'ou=People'},
                }]
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_ldap_auth('ldap') }
      end
      context 'mutators defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            mutators => {
              'test' => { 'command' => 'test' },
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_mutator('test') }
      end
      context 'namespaces defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            namespaces => {
              'test' => { 'ensure' => 'present' },
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_namespace('test') }
      end
      context 'oidc_auths defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            oidc_auths => {
              'oidc' => {
                client_id     => '0oa13ry4ypeDDBpxF357',
                client_secret => 'DlArQRfND4BKBUyO0mE-TL2PWOVwyGjIO1fdk9gX',
                server        => 'https://idp.example.com',
              }
            }
          }
          EOS
        end
        it { should contain_sensu_oidc_auth('oidc') }
      end
      context 'role_bindings defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            role_bindings => {
              'test' => {
                'role_ref' => {'type' => 'Role', 'name' => 'test'},
                'subjects' => [{'type' => 'User', 'name' => 'test'}],
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_role_binding('test') }
      end
      context 'roles defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            roles => {
              'test'  => {
                'rules' => [{'verbs' => ['get','list'], 'resources' => ['checks']}]
              }
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_role('test') }
      end
      context 'secrets defined' do
        let(:pre_condition) do
        <<-EOS
        class { 'sensu::resources':
          secrets => {
            'test' => {'id' => 'test', 'secrets_provider' => 'env'},
          },
        }
        EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_secret('test') }
      end
      context 'secrets_vault_providers defined' do
        let(:pre_condition) do
        <<-EOS
        class { 'sensu::resources':
          secrets_vault_providers => {
            'test' => {
              'address' => 'https://foo.example.com',
              'token'   => 'secret',
              'version' => 'v1',
            },
          }
        }
        EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_secrets_vault_provider('test') }
      end
      context 'users defined' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::resources':
            users => {
              'test' => { 'password' => 'password' },
            }
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should contain_sensu_user('test') }
      end
    end
  end
end
