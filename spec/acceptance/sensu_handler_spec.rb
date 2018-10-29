require 'spec_helper_acceptance'

describe 'sensu_handler', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_handler { 'test':
        type           => 'pipe',
        command        => 'notify.rb',
        socket_host    => '127.0.0.1',
        socket_port    => 1234,
        runtime_assets => ['test'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid handler' do
      on node, 'sensuctl handler info test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('notify.rb')
        expect(data['socket']).to eq({'host' => '127.0.0.1', 'port' => 1234})
        expect(data['runtime_assets']).to eq(['test'])
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
        socket_host    => 'localhost',
        socket_port    => 5678,
        runtime_assets => ['test2'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid handler with updated propery' do
      on node, 'sensuctl handler info test --format json' do
        data = JSON.parse(stdout)
        expect(data['filters']).to eq(['production'])
        expect(data['socket']).to eq({'host' => 'localhost', 'port' => 5678})
        expect(data['runtime_assets']).to eq(['test2'])
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_handler { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl handler info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

