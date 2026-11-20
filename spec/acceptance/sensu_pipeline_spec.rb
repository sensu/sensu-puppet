require 'spec_helper_acceptance'

describe 'sensu_pipeline', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_handler { 'notify':
        type    => 'pipe',
        command => 'notify.rb',
      }
      sensu_pipeline { 'test':
        ensure    => 'present',
        workflows => [
          {
            'name'    => 'notify',
            'handler' => { 'name' => 'notify', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
        ],
        labels      => { 'foo' => 'bar' },
        annotations => { 'note' => 'created by puppet' },
      }
      sensu_pipeline { 'test-api':
        ensure    => 'present',
        workflows => [
          {
            'name'    => 'notify',
            'handler' => { 'name' => 'notify', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
        ],
        labels   => { 'foo' => 'bar' },
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
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have a valid pipeline' do
      on node, 'sensuctl pipeline info test --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['labels']['foo']).to eq('bar')
        expect(data['metadata']['annotations']['note']).to eq('created by puppet')
        expect(data['workflows'].length).to eq(1)
        expect(data['workflows'][0]['name']).to eq('notify')
        expect(data['workflows'][0]['handler']['name']).to eq('notify')
      end
    end

    it 'should have a valid pipeline using API' do
      on node, 'sensuctl pipeline info test-api --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['labels']['foo']).to eq('bar')
        expect(data['workflows'].length).to eq(1)
        expect(data['workflows'][0]['name']).to eq('notify')
      end
    end
  end

  context 'update pipeline' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_handler { 'notify':
        type    => 'pipe',
        command => 'notify.rb',
      }
      sensu_handler { 'alert':
        type    => 'pipe',
        command => 'alert.rb',
      }
      sensu_pipeline { 'test':
        ensure    => 'present',
        workflows => [
          {
            'name'    => 'notify',
            'handler' => { 'name' => 'notify', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
          {
            'name'    => 'alert',
            'handler' => { 'name' => 'alert', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
        ],
        labels => { 'foo' => 'baz' },
      }
      sensu_pipeline { 'test-api':
        ensure    => 'present',
        workflows => [
          {
            'name'    => 'notify',
            'handler' => { 'name' => 'notify', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
          {
            'name'    => 'alert',
            'handler' => { 'name' => 'alert', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
        ],
        labels   => { 'foo' => 'baz' },
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
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have a pipeline with updated workflows and labels' do
      on node, 'sensuctl pipeline info test --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['labels']['foo']).to eq('baz')
        expect(data['workflows'].length).to eq(2)
        expect(data['workflows'].map { |w| w['name'] }).to match_array(['notify', 'alert'])
      end
    end

    it 'should have a pipeline with updated workflows and labels using API' do
      on node, 'sensuctl pipeline info test-api --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['labels']['foo']).to eq('baz')
        expect(data['workflows'].length).to eq(2)
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_pipeline { 'test': ensure => 'absent' }
      sensu_pipeline { 'test-api':
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
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe command('sensuctl pipeline info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl pipeline info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end
