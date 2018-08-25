require 'spec_helper_acceptance'

describe 'sensu_entity', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_entity { 'test':
        entity_class           => 'proxy',
        deregistration_handler => 'slack-handler',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should update an entity' do
      on node, "sensuctl entity info test --format json" do
        data = JSON.parse(stdout)
        expect(data['class']).to eq('proxy')
        expect(data['deregistration']['handler']).to eq('slack-handler')
      end
    end
  end

  context 'updates properties' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_entity { 'test':
        entity_class           => 'proxy',
        deregistration_handler => 'email-handler',
        extended_attributes    => { 'foo' => 'bar' }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid entity with extended_attributes properties' do
      on node, "sensuctl entity info test --format json" do
        data = JSON.parse(stdout)
        expect(data['deregistration']['handler']).to eq('email-handler')
        expect(data['foo']).to eq('bar')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_entity { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl entity info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

