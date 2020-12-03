require 'spec_helper_acceptance'

describe 'sensu_secrets_vault_provider', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_secrets_vault_provider { 'my_vault':
        ensure       => 'present',
        address      => "https://vaultserver.example.com:8200",
        token        => "VAULT_TOKEN",
        version      => "v1",
        max_retries  => 2,
        timeout      => "20s",
        tls          => {
          "ca_cert" => "/etc/ssl/certs/ca-bundle.crt"
        },
        rate_limiter => {
          "limit" => 10,
          "burst" => 100
        },
      }
      sensu_secrets_vault_provider { 'my_vault-token_file':
        ensure       => 'present',
        address      => "https://vaultserver.example.com:8200",
        token_file   => "/tmp/secret",
        version      => "v1",
        max_retries  => 2,
        timeout      => "20s",
        tls          => {
          "ca_cert" => "/etc/ssl/certs/ca-bundle.crt"
        },
        rate_limiter => {
          "limit" => 10,
          "burst" => 100
        },
      }
      sensu_secrets_vault_provider { 'my_vault-api':
        ensure       => 'present',
        address      => "https://vaultserver.example.com:8200",
        token        => "VAULT_TOKEN",
        version      => "v1",
        max_retries  => 2,
        timeout      => "20s",
        tls          => {
          "ca_cert" => "/etc/ssl/certs/ca-bundle.crt"
        },
        rate_limiter => {
          "limit" => 10,
          "burst" => 100
        },
        provider     => 'sensu_api',
      }
      sensu_secret { 'test':
        ensure           => 'present',
        id               => 'secret/database#password',
        secrets_provider => 'my_vault',
      }
      sensu_secret { 'test-api':
        ensure           => 'present',
        id               => 'secret/database#password',
        secrets_provider => 'my_vault',
        provider         => 'sensu_api',
      }
      EOS

      create_remote_file(node, '/tmp/secret', "supersecret\n")
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

    it 'should have a valid VaultProvider' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault' }
        spec = data['spec']
        expect(spec['client']['address']).to eq("https://vaultserver.example.com:8200")
        expect(spec['client']['token']).to eq("VAULT_TOKEN")
        expect(spec['client']['version']).to eq("v1")
        expect(spec['client']["max_retries"]).to eq(2)
        expect(spec['client']["timeout"]).to eq("20s")
        expect(spec['client']["tls"]["ca_cert"]).to eq("/etc/ssl/certs/ca-bundle.crt")
        expect(spec['client']["rate_limiter"]).to eq({'limit' => 10, 'burst' => 100})
      end
    end
    it 'should have a valid VaultProvider' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault-token_file' }
        spec = data['spec']
        expect(spec['client']['address']).to eq("https://vaultserver.example.com:8200")
        expect(spec['client']['token']).to eq("supersecret")
        expect(spec['client']['version']).to eq("v1")
        expect(spec['client']["max_retries"]).to eq(2)
        expect(spec['client']["timeout"]).to eq("20s")
        expect(spec['client']["tls"]["ca_cert"]).to eq("/etc/ssl/certs/ca-bundle.crt")
        expect(spec['client']["rate_limiter"]).to eq({'limit' => 10, 'burst' => 100})
      end
    end
    it 'should have a valid VaultProvider using API' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault-api' }
        spec = data['spec']
        expect(spec['client']['address']).to eq("https://vaultserver.example.com:8200")
        expect(spec['client']['token']).to eq("VAULT_TOKEN")
        expect(spec['client']['version']).to eq("v1")
        expect(spec['client']["max_retries"]).to eq(2)
        expect(spec['client']["timeout"]).to eq("20s")
        expect(spec['client']["tls"]["ca_cert"]).to eq("/etc/ssl/certs/ca-bundle.crt")
        expect(spec['client']["rate_limiter"]).to eq({'limit' => 10, 'burst' => 100})
      end
    end
    it 'should have a valid secret' do
      on node, 'sensuctl secret info test --format json' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('secret/database#password')
        expect(data['provider']).to eq('my_vault')
      end
    end
    it 'should have a valid secret using API' do
      on node, 'sensuctl secret info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('secret/database#password')
        expect(data['provider']).to eq('my_vault')
      end
    end
  end

  context 'updates secrets provider' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_secrets_vault_provider { 'my_vault':
        ensure       => 'present',
        address      => "https://vaultserver.example.com:8201",
        token        => "VAULT_TOKEN1",
        version      => "v1",
        max_retries  => 4,
        timeout      => "40s",
        rate_limiter => {
          "limit" => 20,
          "burst" => 200
        },
      }
      sensu_secrets_vault_provider { 'my_vault-token_file':
        ensure       => 'present',
        address      => "https://vaultserver.example.com:8201",
        token_file   => '/tmp/secret',
        version      => "v1",
        max_retries  => 4,
        timeout      => "40s",
        rate_limiter => {
          "limit" => 20,
          "burst" => 200
        },
      }
      sensu_secrets_vault_provider { 'my_vault-api':
        ensure       => 'present',
        address      => "https://vaultserver.example.com:8201",
        token        => "VAULT_TOKEN1",
        version      => "v1",
        max_retries  => 4,
        timeout      => "40s",
        rate_limiter => {
          "limit" => 20,
          "burst" => 200
        },
        provider     => 'sensu_api',
      }
      sensu_secret { 'test in default':
        ensure           => 'present',
        id               => 'secret/database#secret',
        secrets_provider => 'my_vault',
      }
      sensu_secret { 'test-api in default':
        ensure           => 'present',
        id               => 'secret/database#secret',
        secrets_provider => 'my_vault',
        provider         => 'sensu_api',
      }
      EOS

      create_remote_file(node, '/tmp/secret', "supersecret2\n")
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
      expect(result.stdout).not_to include('VAULT_TOKEN')
      expect(result.stderr).not_to include('VAULT_TOKEN')
    end

    it 'should have a valid VaultProvider' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault' }
        spec = data['spec']
        expect(spec['client']['address']).to eq("https://vaultserver.example.com:8201")
        expect(spec['client']['token']).to eq("VAULT_TOKEN1")
        expect(spec['client']['version']).to eq("v1")
        expect(spec['client']["max_retries"]).to eq(4)
        expect(spec['client']["timeout"]).to eq("40s")
        expect(spec['client']["tls"]).to be_nil
        expect(spec['client']["rate_limiter"]).to eq({'limit' => 20, 'burst' => 200})
      end
    end
    it 'should have a valid VaultProvider using token_file' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault-token_file' }
        spec = data['spec']
        expect(spec['client']['address']).to eq("https://vaultserver.example.com:8201")
        expect(spec['client']['token']).to eq("supersecret2")
        expect(spec['client']['version']).to eq("v1")
        expect(spec['client']["max_retries"]).to eq(4)
        expect(spec['client']["timeout"]).to eq("40s")
        expect(spec['client']["tls"]).to be_nil
        expect(spec['client']["rate_limiter"]).to eq({'limit' => 20, 'burst' => 200})
      end
    end
    it 'should have a valid VaultProvider using API' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault-api' }
        spec = data['spec']
        expect(spec['client']['address']).to eq("https://vaultserver.example.com:8201")
        expect(spec['client']['token']).to eq("VAULT_TOKEN1")
        expect(spec['client']['version']).to eq("v1")
        expect(spec['client']["max_retries"]).to eq(4)
        expect(spec['client']["timeout"]).to eq("40s")
        expect(spec['client']["tls"]).to be_nil
        expect(spec['client']["rate_limiter"]).to eq({'limit' => 20, 'burst' => 200})
      end
    end
    it 'should have a valid secret' do
      on node, 'sensuctl secret info test --format json' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('secret/database#secret')
        expect(data['provider']).to eq('my_vault')
      end
    end
    it 'should have a valid secret using API' do
      on node, 'sensuctl secret info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('secret/database#secret')
        expect(data['provider']).to eq('my_vault')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_secrets_vault_provider { 'my_vault': ensure => 'absent' }
      sensu_secrets_vault_provider { 'my_vault-api': ensure => 'absent', provider => 'sensu_api' }
      sensu_secret { 'test': ensure => 'absent' }
      sensu_secret { 'test-api': ensure => 'absent', provider => 'sensu_api' }
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

    it 'should have removed VaultProvider' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault' }
        expect(data).to be_nil
      end
    end
    it 'should have removed VaultProvider using API' do
      # Dump YAML because 'sensuctl dump' does not yet support '--format json'
      # https://github.com/sensu/sensu-go/issues/3424
      on node, 'sensuctl dump secrets/v1.Provider' do
        resources = []
        dumps = stdout.split('---')
        dumps.each do |d|
          resources << YAML.load(d)
        end
        data = resources.find { |r| r['metadata']['name'] == 'my_vault-api' }
        expect(data).to be_nil
      end
    end
    describe command('sensuctl secret info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl secret info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end
