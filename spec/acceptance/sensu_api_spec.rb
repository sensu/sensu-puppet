require 'spec_helper_acceptance'

describe 'sensu_api providers', if: RSpec.configuration.sensu_mode == 'types' do
  agent = hosts_as('sensu-agent')[0]
  backend = hosts_as('sensu-backend')[0]
  context 'setup' do
    it 'cleans environment' do
      on agent, 'puppet resource package sensu-go-cli ensure=absent'
      on agent, 'rm -rf ~/.config'
    end
    it 'sets up backend' do
      backend_pp = <<-EOS
      include ::sensu::backend
      EOS
      apply_manifest_on(backend, backend_pp, :catch_failures => true)
    end
  end
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        api_host => 'sensu-backend',
      }
      include ::sensu::api
      sensu_check { 'test-api':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        provider      => 'sensu_api',
      }
      sensu_namespace { 'test': ensure => 'present', provider => 'sensu_api' }
      sensu_check { 'test-api in test':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        provider      => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(agent, pp, :catch_failures => true)
        apply_manifest_on(agent, pp, :catch_changes  => true)
      end
    end

    it 'should have valid check using API' do
      on backend, 'sensuctl check info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo'])
        expect(data['handlers']).to eq(['email'])
        expect(data['interval']).to eq(60)
      end
    end

    it 'should have a valid check in namespace using API' do
      on backend, 'sensuctl check info test-api --namespace test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo'])
        expect(data['handlers']).to eq(['email'])
        expect(data['interval']).to eq(60)
      end
    end
  end

  context 'updates check' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        api_host => 'sensu-backend',
      }
      include ::sensu::api
      sensu_check { 'test-api':
        command       => 'check-cpu.rb',
        subscriptions => ['demo2'],
        handlers      => ['email2'],
        interval      => 120,
        provider      => 'sensu_api',
      }
      sensu_check { 'test-api in test':
        command       => 'check-cpu.rb',
        subscriptions => ['demo2'],
        handlers      => ['email2'],
        interval      => 120,
        provider      => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(agent, pp, :catch_failures => true)
        apply_manifest_on(agent, pp, :catch_changes  => true)
      end
    end

    it 'should have valid check using API' do
      on backend, 'sensuctl check info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo2'])
        expect(data['handlers']).to eq(['email2'])
        expect(data['interval']).to eq(120)
      end
    end

    it 'should have a valid check in namespace using API' do
      on backend, 'sensuctl check info test-api --namespace test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo2'])
        expect(data['handlers']).to eq(['email2'])
        expect(data['interval']).to eq(120)
      end
    end
  end

  context 'namespace validation' do
    it 'should produce error' do
      pp = <<-EOS
      class { '::sensu':
        api_host => 'sensu-backend',
      }
      include ::sensu::api
      sensu_check { 'test-no-namespace':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        namespace     => 'dne',
        provider      => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [1,4,6]
      else
        apply_manifest_on(agent, pp, :expect_failures => true)
      end
    end

    describe command('sensuctl check info test-no-namespace'), :node => backend do
      its(:exit_status) { should_not eq 0 }
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      class { '::sensu':
        api_host => 'sensu-backend',
      }
      include ::sensu::api
      sensu_check { 'test-api':
        ensure   => 'absent',
        provider => 'sensu_api',
      }
      sensu_check { 'test-api in test':
        ensure   => 'absent',
        provider => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(agent, pp, :catch_failures => true)
        apply_manifest_on(agent, pp, :catch_changes  => true)
      end
    end

    describe command('sensuctl check info test-api'), :node => backend do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl check info test-api --namespace test'), :node => backend do
      its(:exit_status) { should_not eq 0 }
    end
  end
end
