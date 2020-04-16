require 'spec_helper_acceptance'

describe 'sensu_hook', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_hook { 'test':
        command => 'ps aux',
        labels  => { 'foo' => 'baz' },
        runtime_assets => ['test'],
      }
      sensu_hook { 'test-api':
        command => 'ps aux',
        labels  => { 'foo' => 'baz' },
        runtime_assets => ['test'],
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

    it 'should have a valid hook' do
      on node, 'sensuctl hook info test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('ps aux')
        expect(data['stdin']).to eq(false)
        expect(data['runtime_assets']).to eq(['test'])
        expect(data['metadata']['labels']['foo']).to eq('baz')
      end
    end

    it 'should have a valid hook using API' do
      on node, 'sensuctl hook info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('ps aux')
        expect(data['stdin']).to eq(false)
        expect(data['runtime_assets']).to eq(['test'])
        expect(data['metadata']['labels']['foo']).to eq('baz')
      end
    end
  end

  context 'update hook' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_hook { 'test':
        command => 'ps aux',
        timeout => 120,
        runtime_assets => ['test2'],
        labels  => { 'foo' => 'bar' },
      }
      sensu_hook { 'test-api':
        command => 'ps aux',
        timeout => 120,
        runtime_assets => ['test2'],
        labels  => { 'foo' => 'bar' },
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

    it 'should have a valid hook with updated propery' do
      on node, 'sensuctl hook info test --format json' do
        data = JSON.parse(stdout)
        expect(data['timeout']).to eq(120)
        expect(data['runtime_assets']).to eq(['test2'])
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end

    it 'should have a valid hook with updated propery using API' do
      on node, 'sensuctl hook info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['timeout']).to eq(120)
        expect(data['runtime_assets']).to eq(['test2'])
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_hook { 'test': ensure => 'absent' }
      sensu_hook { 'test-api':
        ensure   => 'absent',
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

    describe command('sensuctl hook info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl hook info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

