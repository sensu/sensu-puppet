require 'spec_helper_acceptance'

describe 'sensu_check', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test':
        command                          => 'check-http.rb',
        subscriptions                    => ['demo'],
        handlers                         => ['email'],
        interval                         => 60,
        check_hooks                      => [
          { 'critical' => ['httpd-restart'] },
        ],
        proxy_requests_entity_attributes => ["entity.Class == 'proxy'"],
        output_metric_format             => 'nagios_perfdata',
        labels                           => { 'foo' => 'baz' }
      }
      sensu_check { 'test2':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid check' do
      on node, 'sensuctl check info test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-http.rb')
        expect(data['publish']).to eq(true)
        expect(data['stdin']).to eq(false)
        expect(data['check_hooks']).to eq([{'critical' => ['httpd-restart']}])
        expect(data['proxy_requests']['entity_attributes']).to eq(["entity.Class == 'proxy'"])
        expect(data['output_metric_format']).to eq('nagios_perfdata')
        expect(data['metadata']['labels']['foo']).to eq('baz')
      end
    end

    it 'should have multiple checks' do
      on node, 'sensuctl check list --format json' do
        data = JSON.parse(stdout)
        expect(data.size).to eq(2)
      end
    end
  end

  context 'updates check' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test':
        command                          => 'check-http.rb',
        subscriptions                    => ['demo'],
        interval                         => 60,
        check_hooks                      => [
          { 'critical' => ['httpd-restart'] },
          { 'warning'  => ['httpd-restart'] },
        ],
        proxy_requests_entity_attributes => ['System.OS==linux'],
        output_metric_format             => 'graphite_plaintext',
        labels                           => { 'foo' => 'bar' }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid check with extended_attributes properties' do
      on node, 'sensuctl check info test --format json' do
        data = JSON.parse(stdout)
        expect(data['check_hooks']).to eq([{'critical' => ['httpd-restart']},{'warning' => ['httpd-restart']}])
        expect(data['proxy_requests']['entity_attributes']).to eq(['System.OS==linux'])
        expect(data['output_metric_format']).to eq('graphite_plaintext')
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl check info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end

  context 'resources purge' do
    it 'should remove without errors' do
      pp = <<-EOS
      resources { 'sensu_check':
        purge => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have no checks' do
      on node, 'sensuctl check list --format json' do
        data = JSON.parse(stdout)
        expect(data.size).to eq(0)
      end
    end
  end
end

