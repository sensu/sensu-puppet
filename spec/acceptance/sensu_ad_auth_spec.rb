require 'spec_helper_acceptance'

describe 'sensu_check', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  before do
    if ! RSpec.configuration.sensu_test_enterprise
      skip("Skipping enterprise tests")
    end
  end
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu::backend':
        license_source => '/root/sensu_license.json',
      }
      sensu_ad_auth { 'activedirectory':
        ensure              => 'present',
        servers             => [
          {
            'host' => '127.0.0.1',
            'port' => 389,
          },
        ],
        server_binding      => {
          '127.0.0.1' => {
            'user_dn' => 'cn=binder,dc=acme,dc=org',
            'password' => 'P@ssw0rd!'
          }
        },
        server_group_search => {
          '127.0.0.1' => {
            'base_dn' => 'dc=acme,dc=org',
          }
        },
        server_user_search  => {
          '127.0.0.1' => {
            'base_dn' => 'dc=acme,dc=org',
          }
        },
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid AD auth' do
      on node, 'sensuctl auth info activedirectory --format json' do
        data = JSON.parse(stdout)
        expect(data['servers'].size).to eq(1)
        expect(data['servers'][0]['host']).to eq('127.0.0.1')
        expect(data['servers'][0]['port']).to eq(389)
        expect(data['servers'][0]['insecure']).to eq(false)
        expect(data['servers'][0]['security']).to eq('tls')
        expect(data['servers'][0]['binding']).to eq({'user_dn' => 'cn=binder,dc=acme,dc=org', 'password' => 'P@ssw0rd!'})
        expect(data['servers'][0]['group_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'})
        expect(data['servers'][0]['user_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'})
      end
    end
  end

  context 'updates auth' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu::backend':
        license_source => '/root/sensu_license.json',
      }
      sensu_ad_auth { 'activedirectory':
        ensure              => 'present',
        servers             => [
          {
            'host' => 'localhost',
            'port' => 636,
          },
        ],
        server_binding      => {
          'localhost' => {
            'user_dn' => 'cn=test,dc=acme,dc=org',
            'password' => 'password'
          }
        },
        server_group_search => {
          'localhost' => {
            'base_dn' => 'dc=acme,dc=org',
          }
        },
        server_user_search  => {
          'localhost' => {
            'base_dn' => 'dc=acme,dc=org',
          }
        },
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid ad auth' do
      on node, 'sensuctl auth info activedirectory --format json' do
        data = JSON.parse(stdout)
        expect(data['servers'].size).to eq(1)
        expect(data['servers'][0]['host']).to eq('localhost')
        expect(data['servers'][0]['port']).to eq(636)
        expect(data['servers'][0]['insecure']).to eq(false)
        expect(data['servers'][0]['security']).to eq('tls')
        expect(data['servers'][0]['binding']).to eq({'user_dn' => 'cn=test,dc=acme,dc=org', 'password' => 'password'})
        expect(data['servers'][0]['group_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'})
        expect(data['servers'][0]['user_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'})
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_ad_auth { 'activedirectory': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl auth info activedirectory'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

