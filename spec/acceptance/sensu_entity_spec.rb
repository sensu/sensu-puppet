require 'spec_helper_acceptance'

describe 'sensu_entity', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_entity { 'test':
        entity_class => 'proxy',
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
      end
    end
  end

  context 'extended_attributes property' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_entity { 'test':
        entity_class        => 'proxy',
        extended_attributes => { 'foo' => 'bar' }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid entity with extended_attributes properties' do
      on node, "sensuctl entity info test --format json" do
        data = JSON.parse(stdout)
        expect(data['foo']).to eq('bar')
      end
    end
  end
end

