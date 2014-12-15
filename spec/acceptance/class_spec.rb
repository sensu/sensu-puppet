require 'spec_helper_acceptance'

describe 'sensu class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'sensu' do
    context 'default' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'sensu':}
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe service('sensu-client') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end

    end #default

    context 'server => true, api => true' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'rabbitmq':
          ssl               => false,
          delete_guest_user => true,
        }
        -> rabbitmq_vhost { 'sensu': }
        -> rabbitmq_user  { 'sensu': password => 'secret' }
        -> rabbitmq_user_permissions { 'sensu@sensu':
          configure_permission => '.*',
          read_permission      => '.*',
          write_permission     => '.*',
        }
        class { 'redis': }
        EOS

        # Set up dependencies
        apply_manifest(pp, :catch_failures => true)

        pp = <<-EOS
        class { 'sensu':
          server                   => true,
          api                      => true,
          purge_config             => true,
          rabbitmq_password        => 'secret',
          rabbitmq_host            => 'localhost',
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe service('sensu-server') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end

      describe service('sensu-client') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end

      describe service('sensu-api') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end

      describe command('curl localhost:4567/info') do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /sensu.*version/ }
      end
    end # server and api

    context 'client => false' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'sensu':
          client => false
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        shell('sleep 5') # Give services time to stop
        apply_manifest(pp, :catch_changes  => true)
      end

      describe service('sensu-client') do
        it { is_expected.not_to be_running }
        it { is_expected.not_to be_enabled }
      end

    end #no client
  end # sensu

end
