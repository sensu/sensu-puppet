require 'spec_helper_acceptance'

describe 'sensu_check', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test':
        command       => 'check-http.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
        check_hooks   => [
          { 'critical' => ['httpd-restart'] },
        ],
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
        expect(data['check_hooks']).to eq([{'critical' => ['httpd-restart']}])
      end
    end
  end

  context 'extended_attributes property' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test':
        command             => 'check-http.rb',
        subscriptions       => ['demo'],
        handlers            => ['email'],
        interval            => 60,
        extended_attributes => { 'foo' => 'bar' }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid check with extended_attributes properties' do
      on node, 'sensuctl check info test --format json' do
        data = JSON.parse(stdout)
        expect(data['foo']).to eq('bar')
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
end

