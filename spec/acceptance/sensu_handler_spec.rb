require 'spec_helper_acceptance'

describe 'sensu_handler', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_handler { 'test':
        type           => 'pipe',
        command        => 'notify.rb',
        runtime_assets => ['test'],
        labels         => { 'foo' => 'baz' },
      }
      sensu_handler { 'test2':
        type           => 'tcp',
        socket         => {'host' => '127.0.0.1', 'port' => 1234},
        labels         => { 'foo' => 'bar' },
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

    it 'should have a valid pipe handler' do
      on node, 'sensuctl handler info test --format json' do
        data = JSON.parse(stdout)
        expect(data['type']).to eq('pipe')
        expect(data['timeout']).to eq(0)
        expect(data['command']).to eq('notify.rb')
        expect(data['metadata']['labels']['foo']).to eq('baz')
      end
    end

    it 'should have a valid tcp handler' do
      on node, 'sensuctl handler info test2 --format json' do
        data = JSON.parse(stdout)
        expect(data['type']).to eq('tcp')
        expect(data['timeout']).to eq(60)
        expect(data['socket']).to eq({'host' => '127.0.0.1', 'port' => 1234})
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end
  end

  context 'update handler' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_handler { 'test':
        type           => 'pipe',
        command        => 'notify.rb',
        filters        => ['production'],
        runtime_assets => ['test2'],
        labels         => { 'foo' => 'bar' },
      }
      sensu_handler { 'test2':
        type           => 'tcp',
        socket         => {'host' => 'localhost', 'port' => 5678},
        labels         => { 'foo' => 'bar' },
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

    it 'should have a valid pipe handler with updated propery' do
      on node, 'sensuctl handler info test --format json' do
        data = JSON.parse(stdout)
        expect(data['filters']).to eq(['production'])
        expect(data['runtime_assets']).to eq(['test2'])
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end

    it 'should have a valid tcp handler with updated propery' do
      on node, 'sensuctl handler info test2 --format json' do
        data = JSON.parse(stdout)
        expect(data['socket']).to eq({'host' => 'localhost', 'port' => 5678})
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_handler { 'test': ensure => 'absent' }
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

    describe command('sensuctl handler info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

