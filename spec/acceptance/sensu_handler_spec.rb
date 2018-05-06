require 'spec_helper_acceptance'

describe 'sensu_handler', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_handler { 'test':
        type          => 'pipe',
        command       => 'notify.rb'
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
      end
    end
  end

  context 'with custom properties' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_handler { 'test':
        type          => 'pipe',
        command       => 'notify.rb',
        custom        => { 'foo' => 'bar' },
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid handler with custom propery' do
      on node, 'sensuctl handler info test --format json' do
        data = JSON.parse(stdout)
        expect(data['foo']).to eq('bar')
      end
    end
  end
end

