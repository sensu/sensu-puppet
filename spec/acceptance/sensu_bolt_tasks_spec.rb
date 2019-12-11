require 'spec_helper_acceptance'

describe 'sensu event task', if: RSpec.configuration.sensu_full do
  backend = hosts_as('sensu_backend')[0]
  agent = hosts_as('sensu_agent')[0]
  context 'setup agent' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu::agent':
        backends    => ['sensu_backend:8081'],
        entity_name => 'sensu_agent',
      }
      EOS

      apply_manifest_on(agent, pp, :catch_failures => true)
      apply_manifest_on(backend, 'include ::sensu::backend', :catch_failures => true)
    end
  end

  context 'resolve' do
    it 'should work without errors' do
      check_pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test':
        command       => 'exit 1',
        subscriptions => ['entity:sensu_agent'],
        interval      => 3600,
      }
      EOS

      apply_manifest_on(backend, check_pp, :catch_failures => true)
      on backend, 'sensuctl check execute test'
      sleep 20
      on backend, 'bolt task run sensu::event action=resolve entity=sensu_agent check=test --nodes sensu_backend'
    end

    it 'should have resolved check' do
      on backend, 'sensuctl event info sensu_agent test --format json' do
        data = JSON.parse(stdout)
        expect(data['check']['status']).to eq(0)
      end
    end
  end

  context 'delete' do
    it 'should remove without errors' do
      # Stop sensu-agent on agent node to avoid re-creating event
      apply_manifest_on(agent,
        "service { 'sensu-agent': ensure => 'stopped' }")
      sleep 20
      on backend, 'bolt task run sensu::event action=delete entity=sensu_agent check=test --nodes sensu_backend'
    end

    describe command('sensuctl event info sensu_agent test'), :node => backend do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

describe 'sensu silenced task', if: RSpec.configuration.sensu_full do
  backend = hosts_as('sensu_backend')[0]
  context 'setup agent' do
    it 'should work without errors' do
      apply_manifest_on(backend, 'include ::sensu::backend', :catch_failures => true)
    end
  end

  context 'create' do
    it 'should work without errors' do
      on backend, 'bolt task run sensu::silenced action=create subscription=entity:sensu_agent --nodes localhost'
    end

    it 'should have a valid silenced' do
      on backend, 'sensuctl silenced info entity:sensu_agent:* --format json' do
        data = JSON.parse(stdout)
        expect(data['subscription']).to eq('entity:sensu_agent')
        expect(data['expire']).to eq(-1)
        expect(data['expire_on_resolve']).to eq(false)
      end
    end
  end

  context 'update' do
    it 'should work without errors' do
      on backend, 'bolt task run sensu::silenced action=create subscription=entity:sensu_agent expire_on_resolve=true --nodes localhost'
    end

    it 'should have a valid silenced with updated propery' do
      on backend, 'sensuctl silenced info entity:sensu_agent:* --format json' do
        data = JSON.parse(stdout)
        expect(data['expire_on_resolve']).to eq(true)
      end
    end
  end

  context 'delete' do
    it 'should remove without errors' do
      on backend, 'bolt task run sensu::silenced action=delete subscription=entity:sensu_agent --nodes localhost'
    end

    describe command('sensuctl silenced info entity:sensu_agent:*'), :node => backend do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

describe 'sensu install_agent task', if: RSpec.configuration.sensu_full do
  backend = hosts_as('sensu_backend')[0]
  agent = hosts_as('sensu_agent')[0]
  context 'setup' do
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu':
        use_ssl => false,
      }
      include '::sensu::backend'
      sensu_entity { 'sensu_agent':
        ensure => 'absent',
      }
      EOS

      on agent, 'puppet resource service sensu-agent ensure=stopped'
      if fact('os.family') == 'RedHat'
        on agent, 'rm -f /etc/yum.repos.d/sensu.repo'
      end
      if fact('os.family') == 'Debian'
        on agent, 'rm -f /etc/apt/sources.list.d/sensu.list'
        on agent, 'apt-get update'
      end
      on agent, 'puppet resource package sensu-go-agent ensure=absent'
      on agent, 'rm -rf /etc/sensu'
      apply_manifest_on(backend, pp, :catch_failures => true)
    end
  end
  context 'install_agent' do
    it 'should work without errors' do
      on backend, 'bolt task run sensu::install_agent backend=sensu_backend:8081 subscription=linux output=true --nodes sensu_agent'
      sleep 5
    end

    it 'should have a valid entity' do
      on backend, 'sensuctl entity info sensu_agent --format json' do
        data = JSON.parse(stdout)
        expect(data['subscriptions']).to include('linux')
        expect(data['metadata']['namespace']).to eq('default')
      end
    end
  end
end

describe 'sensu check_execute task', if: RSpec.configuration.sensu_full do
  backend = hosts_as('sensu_backend')[0]
  agent = hosts_as('sensu_agent')[0]
  context 'setup' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test':
        command       => 'exit 1',
        subscriptions => ['entity:sensu_agent'],
        interval      => 3600,
      }
      EOS
      agent_pp = <<-EOS
      class { '::sensu::agent':
        backends    => ['sensu_backend:8081'],
        entity_name => 'sensu_agent',
      }
      EOS
      apply_manifest_on(backend, pp, :catch_failures => true)
      apply_manifest_on(agent, agent_pp, :catch_failures => true)
    end
  end
  context 'check_execute' do
    it 'should work without errors' do
      on backend, 'bolt task run sensu::check_execute check=test subscription=entity:sensu_agent --nodes localhost'
      sleep 30
    end

    it 'should have executed check' do
      on backend, 'sensuctl event info sensu_agent test --format json' do
        data = JSON.parse(stdout)
        expect(data['check']['status']).to eq(1)
      end
    end
  end
end

describe 'sensu assets_outdated task', if: RSpec.configuration.sensu_full do
  backend = hosts_as('sensu_backend')[0]
  context 'setup' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler': version => '1.0.2' }
      EOS
      apply_manifest_on(backend, pp, :catch_failures => true)
    end
  end

  context 'assets_outdated' do
    it 'should return outdated assets' do
      on backend, 'bolt task run sensu::assets_outdated --nodes localhost --format json' do
        data = JSON.parse(stdout)
        d = data['items'][0]['result']['data']
        expect(d[0]['asset_name']).to eq('sensu/sensu-pagerduty-handler')
      end
    end
  end
end

describe 'sensu apikey task', if: RSpec.configuration.sensu_full do
  backend = hosts_as('sensu_backend')[0]
  context 'setup' do
    it 'should work without errors' do
      apply_manifest_on(backend, 'include ::sensu::backend', :catch_failures => true)
    end
  end

  context 'create' do
    it 'should work without errors' do
      on backend, 'bolt task run sensu::apikey action=create username=admin --nodes sensu_backend'
    end

    it 'should have created api key' do
      on backend, 'sensuctl api-key list --format json' do
        data = JSON.parse(stdout)
        key = data.select { |k| k["username"] == "admin" }[0]
        expect(key).not_to be_nil
      end
    end
  end

  context 'list' do
    describe command('bolt task run sensu::apikey action=list --nodes sensu_backend'), :node => backend do
      its(:exit_status) { should eq 0 }
    end
  end

  context 'delete' do
    it 'should remove without errors' do
      key = nil
      # Get key
      on backend, 'sensuctl api-key list --format json' do
        data = JSON.parse(stdout)
        apikey = data.select { |k| k["username"] == "admin" }[0]
        key = apikey["metadata"]["name"]
      end
      on backend, "bolt task run sensu::apikey action=delete key=#{key} --nodes sensu_backend"
    end
  end
end

describe 'sensu agent_event task', if: RSpec.configuration.sensu_full do
  backend = hosts_as('sensu_backend')[0]
  agent = hosts_as('sensu_agent')[0]
  context 'setup' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      EOS
      agent_pp = <<-EOS
      class { '::sensu::agent':
        backends    => ['sensu_backend:8081'],
        entity_name => 'sensu_agent',
      }
      EOS
      apply_manifest_on(agent, agent_pp, :catch_failures => true)
      apply_manifest_on(backend, pp, :catch_failures => true)
    end
  end
  context 'agent_event' do
    it 'should work without errors' do
      on backend, 'bolt task run sensu::agent_event name=bolttest status=1 output=test --nodes sensu_agent'
      sleep 5
    end

    it 'should have created an event' do
      on backend, 'sensuctl event info sensu_agent bolttest --format json' do
        data = JSON.parse(stdout)
        expect(data['check']['status']).to eq(1)
        expect(data['check']['output']).to eq('test')
      end
    end
  end
end
