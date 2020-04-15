require 'spec_helper_acceptance'

describe 'sensu_entity', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_entity { 'test':
        entity_class           => 'proxy',
        deregistration         => {'handler' => 'slack-handler'},
      }
      sensu_entity { 'test-api':
        entity_class           => 'proxy',
        deregistration         => {'handler' => 'slack-handler'},
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

    it 'should create an entity' do
      on node, "sensuctl entity info test --format json" do
        data = JSON.parse(stdout)
        expect(data['entity_class']).to eq('proxy')
        expect(data['deregister']).to eq(false)
        expect(data['deregistration']['handler']).to eq('slack-handler')
      end
    end

    it 'should create an entity using API' do
      on node, "sensuctl entity info test-api --format json" do
        data = JSON.parse(stdout)
        expect(data['entity_class']).to eq('proxy')
        expect(data['deregister']).to eq(false)
        expect(data['deregistration']['handler']).to eq('slack-handler')
      end
    end
  end

  context 'updates properties' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_entity { 'test':
        entity_class           => 'proxy',
        deregistration         => {'handler' => 'email-handler'},
        labels                 => { 'foo' => 'bar' }
      }
      sensu_entity { 'test-api':
        entity_class           => 'proxy',
        deregistration         => {'handler' => 'email-handler'},
        labels                 => { 'foo' => 'bar' }
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

    it 'should have a valid entity with extended_attributes properties' do
      on node, "sensuctl entity info test --format json" do
        data = JSON.parse(stdout)
        expect(data['deregistration']['handler']).to eq('email-handler')
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end

    it 'should have a valid entity with extended_attributes properties with API' do
      on node, "sensuctl entity info test-api --format json" do
        data = JSON.parse(stdout)
        expect(data['deregistration']['handler']).to eq('email-handler')
        expect(data['metadata']['labels']['foo']).to eq('bar')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_entity { 'test': ensure => 'absent' }
      sensu_entity { 'test-api':
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

    describe command('sensuctl entity info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl entity info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

