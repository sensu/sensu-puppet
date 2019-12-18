require 'spec_helper_acceptance'

describe 'sensu_filter', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_filter { 'test':
        action         => 'allow',
        expressions    => ["event.entity.labels.environment == 'production'"],
        runtime_assets => ['test'],
        labels         => { 'foo' => 'baz' },
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

    it 'should have a valid filter' do
      on node, 'sensuctl filter info test --format json' do
        data = JSON.parse(stdout)
        expect(data['action']).to eq('allow')
        expect(data['expressions']).to eq(["event.entity.labels.environment == 'production'"])
        expect(data['runtime_assets']).to eq(['test'])
        expect(data['metadata']['labels']['foo']).to eq('baz')
      end
    end
  end

  context 'update filter' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_filter { 'test':
        action     => 'allow',
        expressions => ["event.entity.labels.environment == 'test'"],
        runtime_assets => ['test2'],
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

    it 'should have a valid filter with updated propery' do
      on node, 'sensuctl filter info test --format json' do
        data = JSON.parse(stdout)
        expect(data['expressions']).to eq(["event.entity.labels.environment == 'test'"])
        expect(data['runtime_assets']).to eq(['test2'])
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_filter { 'test': ensure => 'absent' }
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

    describe command('sensuctl filter info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

