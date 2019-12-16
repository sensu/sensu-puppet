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
      class { 'sensu::backend':
        license_source => '/root/sensu_license.json',
      }
      sensu_oidc_auth { 'oidc':
        ensure            => 'present',
        additional_scopes => ['email','groups'],
        client_id         => '0oa13ry4ypeDDBpxF357',
        client_secret     => 'DlArQRfND4BKBUyO0mE-TL2PWOVwyGjIO1fdk9gX',
        groups_claim      => 'groups',
        groups_prefix     => 'oidc:',
        redirect_uri      => 'https://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback',
        server            => 'https://idp.example.com',
        username_claim    => 'email',
        username_prefix   => 'oidc:',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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

    it 'should have a valid OIDC auth' do
      on node, 'sensuctl auth info oidc --format json' do
        data = JSON.parse(stdout)
        expect(data['client_id']).to eq('0oa13ry4ypeDDBpxF357')
        expect(data['client_secret']).to eq('DlArQRfND4BKBUyO0mE-TL2PWOVwyGjIO1fdk9gX')
        expect(data['server']).to eq('https://idp.example.com')
        expect(data['groups_claim']).to eq('groups')
        expect(data['groups_prefix']).to eq('oidc:')
        expect(data['username_claim']).to eq('email')
        expect(data['username_prefix']).to eq('oidc:')
        expect(data['redirect_uri']).to eq('https://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback')
        expect(data['additional_scopes']).to eq(['email','groups'])
      end
    end
  end

  context 'updates auth' do
    it 'should work without errors' do
      pp = <<-EOS
      class { 'sensu::backend':
        license_source => '/root/sensu_license.json',
      }
      sensu_oidc_auth { 'oidc':
        ensure            => 'present',
        additional_scopes => ['email','groups','openid'],
        client_id         => '0oa13ry4ypeDDBpxF357',
        client_secret     => 'secret',
        groups_claim      => 'roles',
        groups_prefix     => 'oidc:',
        redirect_uri      => 'https://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback',
        server            => 'https://idp.example.com',
        username_claim    => 'username',
        username_prefix   => 'oidc:',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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

    it 'should have a valid OIDC auth' do
      on node, 'sensuctl auth info oidc --format json' do
        data = JSON.parse(stdout)
        expect(data['client_id']).to eq('0oa13ry4ypeDDBpxF357')
        expect(data['client_secret']).to eq('secret')
        expect(data['server']).to eq('https://idp.example.com')
        expect(data['groups_claim']).to eq('roles')
        expect(data['groups_prefix']).to eq('oidc:')
        expect(data['username_claim']).to eq('username')
        expect(data['username_prefix']).to eq('oidc:')
        expect(data['redirect_uri']).to eq('https://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback')
        expect(data['additional_scopes']).to eq(['email','groups','openid'])
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_oidc_auth { 'oidc': ensure => 'absent' }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
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

    describe command('sensuctl auth info oidc'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

