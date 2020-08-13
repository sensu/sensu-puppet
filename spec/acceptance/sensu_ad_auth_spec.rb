require 'spec_helper_acceptance'

describe 'sensu_ad_auth', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_ad_auth { 'activedirectory':
        ensure              => 'present',
        servers             => [
          {
            'host' => '127.0.0.1',
            'port' => 389,
            'binding'      => {
              'user_dn' => 'cn=binder,dc=acme,dc=org',
              'password' => 'P@ssw0rd!'
            },
            'user_search'  => {
              'base_dn' => 'dc=acme,dc=org',
            },
          }
        ]
      }
      sensu_ad_auth { 'activedirectory-api':
        ensure              => 'present',
        servers             => [
          {
            'host' => '127.0.0.1',
            'port' => 389,
            'binding'      => {
              'user_dn' => 'cn=binder,dc=acme,dc=org',
              'password' => 'P@ssw0rd!'
            },
            'user_search'  => {
              'base_dn' => 'dc=acme,dc=org',
            },
          }
        ],
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

    it 'should have a valid AD auth' do
      on node, 'sensuctl auth info activedirectory --format json' do
        data = JSON.parse(stdout)
        expect(data['servers'].size).to eq(1)
        expect(data['servers'][0]['host']).to eq('127.0.0.1')
        expect(data['servers'][0]['port']).to eq(389)
        expect(data['servers'][0]['insecure']).to eq(false)
        expect(data['servers'][0]['security']).to eq('tls')
        expect(data['servers'][0]['default_upn_domain']).to eq('')
        expect(data['servers'][0]['include_nested_groups']).to be_nil
        expect(data['servers'][0]['binding']).to eq({'user_dn' => 'cn=binder,dc=acme,dc=org', 'password' => 'P@ssw0rd!'})
        expect(data['servers'][0]['group_search']).to eq({'base_dn' => '','attribute' => '','name_attribute' => '','object_class' => ''})
        expect(data['servers'][0]['user_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'})
      end
    end

    it 'should have a valid AD auth using API' do
      on node, 'sensuctl auth info activedirectory-api --format json' do
        data = JSON.parse(stdout)
        expect(data['servers'].size).to eq(1)
        expect(data['servers'][0]['host']).to eq('127.0.0.1')
        expect(data['servers'][0]['port']).to eq(389)
        expect(data['servers'][0]['insecure']).to eq(false)
        expect(data['servers'][0]['security']).to eq('tls')
        expect(data['servers'][0]['default_upn_domain']).to eq('')
        expect(data['servers'][0]['include_nested_groups']).to be_nil
        expect(data['servers'][0]['binding']).to eq({'user_dn' => 'cn=binder,dc=acme,dc=org', 'password' => 'P@ssw0rd!'})
        expect(data['servers'][0]['group_search']).to eq({'base_dn' => '','attribute' => '','name_attribute' => '','object_class' => ''})
        expect(data['servers'][0]['user_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'})
      end
    end
  end

  context 'updates auth' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_ad_auth { 'activedirectory':
        ensure              => 'present',
        servers             => [
          {
            'host' => 'localhost',
            'port' => 636,
            'default_upn_domain' => 'example.com',
            'include_nested_groups' => true,
            'binding'      => {
              'user_dn' => 'cn=test,dc=acme,dc=org',
              'password' => 'supersecret'
            },
            'group_search' => {
              'base_dn' => 'dc=acme,dc=org',
            },
            'user_search'  => {
              'base_dn' => 'dc=acme,dc=org',
            },
          }
        ]
      }
      sensu_ad_auth { 'activedirectory-api':
        ensure              => 'present',
        servers             => [
          {
            'host' => 'localhost',
            'port' => 636,
            'default_upn_domain' => 'example.com',
            'include_nested_groups' => true,
            'binding'      => {
              'user_dn' => 'cn=test,dc=acme,dc=org',
              'password' => 'supersecret'
            },
            'group_search' => {
              'base_dn' => 'dc=acme,dc=org',
            },
            'user_search'  => {
              'base_dn' => 'dc=acme,dc=org',
            },
          }
        ],
        provider => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        result = on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        result = apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
      expect(result.stdout).not_to include('P@ssw0rd!')
      expect(result.stderr).not_to include('P@ssw0rd!')
      expect(result.stdout).not_to include('supersecret')
      expect(result.stderr).not_to include('supersecret')
    end

    it 'should have a valid ad auth' do
      on node, 'sensuctl auth info activedirectory --format json' do
        data = JSON.parse(stdout)
        expect(data['servers'].size).to eq(1)
        expect(data['servers'][0]['host']).to eq('localhost')
        expect(data['servers'][0]['port']).to eq(636)
        expect(data['servers'][0]['insecure']).to eq(false)
        expect(data['servers'][0]['security']).to eq('tls')
        expect(data['servers'][0]['default_upn_domain']).to eq('example.com')
        expect(data['servers'][0]['include_nested_groups']).to eq(true)
        expect(data['servers'][0]['binding']).to eq({'user_dn' => 'cn=test,dc=acme,dc=org', 'password' => 'supersecret'})
        expect(data['servers'][0]['group_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'})
        expect(data['servers'][0]['user_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'})
      end
    end

    it 'should have a valid ad auth using API' do
      on node, 'sensuctl auth info activedirectory-api --format json' do
        data = JSON.parse(stdout)
        expect(data['servers'].size).to eq(1)
        expect(data['servers'][0]['host']).to eq('localhost')
        expect(data['servers'][0]['port']).to eq(636)
        expect(data['servers'][0]['insecure']).to eq(false)
        expect(data['servers'][0]['security']).to eq('tls')
        expect(data['servers'][0]['default_upn_domain']).to eq('example.com')
        expect(data['servers'][0]['include_nested_groups']).to eq(true)
        expect(data['servers'][0]['binding']).to eq({'user_dn' => 'cn=test,dc=acme,dc=org', 'password' => 'supersecret'})
        expect(data['servers'][0]['group_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'member','name_attribute' => 'cn','object_class' => 'group'})
        expect(data['servers'][0]['user_search']).to eq({'base_dn' => 'dc=acme,dc=org','attribute' => 'sAMAccountName','name_attribute' => 'displayName','object_class' => 'person'})
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_ad_auth { 'activedirectory': ensure => 'absent' }
      sensu_ad_auth { 'activedirectory-api': ensure => 'absent', provider => 'sensu_api' }
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

    describe command('sensuctl auth info activedirectory'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl auth info activedirectory-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

