require 'spec_helper_acceptance'

describe 'sensu_event' do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_event { 'keepalive for sensu_agent':
        ensure => 'resolve',
      }
      EOS

      # There should be no changes
      apply_manifest_on(node, pp, :catch_changes  => true)
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      # Stop sensu-agent on agent node to avoid re-creating event
      apply_manifest_on(only_host_with_role(hosts, 'sensu_agent'),
        "service { 'sensu-agent': ensure => 'stopped' }")
      pp = <<-EOS
      include ::sensu::backend
      sensu_event { 'keepalive for sensu_agent':
        ensure => 'absent',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl event info sensu_agent keepalive'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

