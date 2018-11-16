require 'spec_helper_acceptance'

describe 'sensu_filter', if: RSpec.configuration.sensu_full do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_filter { 'test':
        action         => 'allow',
        expressions    => ["event.Entity.Environment == 'production'"],
        when_days      => {'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]},
        runtime_assets => ['test'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid filter' do
      on node, 'sensuctl filter info test --format json' do
        data = JSON.parse(stdout)
        expect(data['action']).to eq('allow')
        expect(data['expressions']).to eq(["event.Entity.Environment == 'production'"])
        expect(data['when']['days']).to eq({'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]})
        expect(data['runtime_assets']).to eq(['test'])
      end
    end
  end

  context 'update filter' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_filter { 'test':
        action     => 'allow',
        expressions => ["event.Entity.Environment == 'test'"],
        when_days  => {
          'monday'  => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}],
          'tuesday' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}],
        },
        runtime_assets => ['test2'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid filter with updated propery' do
      on node, 'sensuctl filter info test --format json' do
        data = JSON.parse(stdout)
        expect(data['expressions']).to eq(["event.Entity.Environment == 'test'"])
        expect(data['when']['days']).to eq({'monday' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}],'tuesday' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]})
        expect(data['runtime_assets']).to eq(['test2'])
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_filter { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl filter info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

