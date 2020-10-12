require 'spec_helper_acceptance'

describe 'sensu_check', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_check { 'test':
        command                          => 'check-http.rb',
        subscriptions                    => ['demo'],
        handlers                         => ['email'],
        interval                         => 60,
        check_hooks                      => [
          { '0'        => ['always.sh'] },
          { 1          => ['test.sh'] },
          { 'critical' => ['httpd-restart'] },
        ],
        proxy_requests                   => {
          'entity_attributes' => ["entity.Class == 'proxy'"],
        },
        output_metric_format             => 'nagios_perfdata',
        output_metric_tags               => [{'name' => 'instance', 'value' => '{{ .name }}'}],
        labels                           => { 'foo' => 'baz' },
        secrets                          => [
          {'name' => 'TEST', 'secret' => 'test'}
        ],
      }
      sensu_check { 'test2':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      sensu_check { 'test-api':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        provider      => 'sensu_api',
      }
      sensu_namespace { 'test': ensure => 'present' }
      sensu_check { 'test2 in test':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      sensu_check { 'test-api in test':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        provider      => 'sensu_api',
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

    it 'should have a valid check' do
      on node, 'sensuctl check info test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-http.rb')
        expect(data['publish']).to eq(true)
        expect(data['stdin']).to eq(false)
        expect(data['check_hooks']).to eq([{'0' => ['always.sh']},{'1' => ['test.sh']},{'critical' => ['httpd-restart']}])
        expect(data['proxy_requests']['entity_attributes']).to eq(["entity.Class == 'proxy'"])
        expect(data['output_metric_format']).to eq('nagios_perfdata')
        expect(data['output_metric_tags']).to eq([{'name' => 'instance', 'value' => '{{ .name }}'}])
        expect(data['metadata']['labels']['foo']).to eq('baz')
        expect(data['secrets']).to eq([{'name' => 'TEST', 'secret' => 'test'}])
      end
    end

    it 'should have valid check using API' do
      on node, 'sensuctl check info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo'])
        expect(data['handlers']).to eq(['email'])
        expect(data['interval']).to eq(60)
      end
    end

    it 'should have a valid check in namespace' do
      on node, 'sensuctl check info test2 --namespace test --format json' do
        data = JSON.parse(stdout)
        expect(data['metadata']['name']).to eq('test2')
        expect(data['metadata']['namespace']).to eq('test')
      end
    end

    it 'should have a valid check in namespace using API' do
      on node, 'sensuctl check info test-api --namespace test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo'])
        expect(data['handlers']).to eq(['email'])
        expect(data['interval']).to eq(60)
      end
    end
  end

  context 'with chunk size' do
    it 'should work without errors' do
      pp = <<-EOS
      class { 'sensu::cli':
        sensuctl_chunk_size => 1,
      }
      include sensu::backend
      sensu_check { 'test3':
        command       => 'check-http3.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      sensu_check { 'test4':
        command       => 'check-cpu4.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
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
  end

  context 'updates check' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_check { 'test':
        command                          => 'check-http.rb',
        subscriptions                    => ['demo'],
        interval                         => 60,
        check_hooks                      => [
          { 'critical' => ['httpd-restart'] },
          { 'warning'  => ['httpd-restart'] },
        ],
        proxy_requests                   => {
          'entity_attributes' => ['System.OS==linux'],
        },
        output_metric_format             => 'graphite_plaintext',
        output_metric_tags               => [
          {'name' => 'instance', 'value' => '{{ .name }}'},
          {'name' => 'prometheus_type', 'value' => 'gauge'},
        ],
        labels                           => { 'foo' => 'bar' },
        secrets                          => [
          {'name' => 'TEST', 'secret' => 'test2'}
        ],
      }
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

    it 'should have a valid check with extended_attributes properties' do
      on node, 'sensuctl check info test --format json' do
        data = JSON.parse(stdout)
        expect(data['check_hooks']).to eq([{'critical' => ['httpd-restart']},{'warning' => ['httpd-restart']}])
        expect(data['proxy_requests']['entity_attributes']).to eq(['System.OS==linux'])
        expect(data['output_metric_format']).to eq('graphite_plaintext')
        expect(data['output_metric_tags']).to include({'name' => 'instance', 'value' => '{{ .name }}'})
        expect(data['output_metric_tags']).to include({'name' => 'prometheus_type', 'value' => 'gauge'})
        expect(data['output_metric_tags'].size).to eq(2)
        expect(data['metadata']['labels']['foo']).to eq('bar')
        expect(data['secrets']).to eq([{'name' => 'TEST', 'secret' => 'test2'}])
      end
    end

    it 'should have valid check using API' do
      on node, 'sensuctl check info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo2'])
        expect(data['handlers']).to eq(['email2'])
        expect(data['interval']).to eq(120)
      end
    end

    it 'should have a valid check in namespace using API' do
      on node, 'sensuctl check info test-api --namespace test --format json' do
        data = JSON.parse(stdout)
        expect(data['command']).to eq('check-cpu.rb')
        expect(data['subscriptions']).to eq(['demo2'])
        expect(data['handlers']).to eq(['email2'])
        expect(data['interval']).to eq(120)
      end
    end
  end

  context 'namespace validation when exists' do
    it 'should produce no error' do
      namespace_pp = <<-EOS
      include sensu::backend
      sensu_namespace { 'devs': ensure => 'present' }
      EOS
      pp = <<-EOS
      include sensu::backend
      sensu_check { 'test-namespace':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        namespace     => 'devs',
      }
      EOS

      apply_manifest_on(node, namespace_pp, :catch_failures => true)
      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
      else
        apply_manifest_on(node, pp, :catch_failures => true)
      end
    end

    describe command('sensuctl check info test-namespace --namespace devs'), :node => node do
      its(:exit_status) { should eq 0 }
    end
  end

  context 'namespace validation' do
    it 'should produce error' do
      pp = <<-EOS
      include sensu::backend
      sensu_check { 'test-no-namespace':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        namespace     => 'dne',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [1,4,6]
      else
        apply_manifest_on(node, pp, :expect_failures => true)
      end
    end

    describe command('sensuctl check info test-no-namespace'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_check { 'test': ensure => 'absent' }
      sensu_check { 'test-api':
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

    describe command('sensuctl check info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end

  context 'resources purge' do
    it 'should remove without errors' do
      before_pp = <<-EOS
      include sensu::backend
      sensu_namespace { 'dev': ensure => 'present' }
      sensu_check { 'test1':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      sensu_check { 'test1 in dev':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      EOS
      pp = <<-EOS
      include sensu::backend
      sensu_namespace { 'dev': ensure => 'present' }
      sensu_check { 'test':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      sensu_check { 'test in dev':
        command       => 'check-cpu.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      sensu_resources { 'sensu_check':
        purge => true,
      }
      EOS

      apply_manifest_on(node, before_pp, :catch_failures => true)
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

    it 'should have purged checks' do
      on node, 'sensuctl check list --format json --all-namespaces' do
        data = JSON.parse(stdout) || []
        expect(data.size).to eq(2)
      end
    end
  end
end

