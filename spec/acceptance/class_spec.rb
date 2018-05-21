require 'spec_helper_acceptance'

describe 'sensu class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'sensu' do
    context 'default' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'sensu':}
        EOS

        # Run it twice and test for idempotency
        if fact('osfamily') == 'windows'
          execute_manifest_on(pp, :catch_failures => true)
          execute_manifest_on(pp, :catch_changes => true)
        else
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end
      end

      describe service('sensu-client') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end

    end #default

    context 'server => true, api => true' do
      if fact('osfamily') == 'windows'
        before { skip("Server not supported on Windows") }
      end
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'sensu':
          server                   => true,
          api                      => true,
          purge                    => true,
          rabbitmq_password        => 'secret',
          rabbitmq_host            => '127.0.0.1',
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
    end # server and api

    if ENV['SE_USER'] && ENV['SE_PASS']
      context 'enterprise => true and enterprise_dashboard => true' do
        if fact('osfamily') == 'windows'
          before { skip("Enterprise not supported on Windows") }
        end
        it 'should work with no errors' do
          pp = <<-EOS
          class { 'sensu':
            enterprise           => true,
            enterprise_dashboard => true,
            enterprise_user      => '#{ENV['SE_USER']}',
            enterprise_pass      => '#{ENV['SE_PASS']}',
            rabbitmq_password    => 'secret',
            rabbitmq_host        => '127.0.0.1',
          }
          sensu::enterprise::dashboard::api { 'sensu.example.com':
            datacenter => 'example-dc',
          }
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_failures => true)
        end

        describe file('/etc/sensu/dashboard.json') do
          it { is_expected.to be_file }
          its(:content) { should match /name.*?example-dc/ }
          its(:content) { should match /host.*?sensu\.example\.com/ }
        end

        describe service('sensu-server') do
          it { is_expected.to_not be_running }
          it { is_expected.to_not be_enabled }
        end

        describe service('sensu-client') do
          it { is_expected.to be_running }
          it { is_expected.to be_enabled }
        end

        describe service('sensu-enterprise') do
          it { is_expected.to be_running }
          it { is_expected.to be_enabled }
        end

        describe service('sensu-enterprise-dashboard') do
          it { is_expected.to be_running }
          it { is_expected.to be_enabled }
        end

        describe service('sensu-api') do
          it { is_expected.to_not be_running }
          it { is_expected.to_not be_enabled }
        end
      end # enterprise and enterprise_dashboard
    end

    context 'client => false' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'sensu':
          client => false
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        if fact('osfamily') == 'windows'
          shell('waitfor SomethingThatIsNeverHappening /t 5 2>NUL', :acceptable_exit_codes => [0,1])
          execute_manifest_on(pp, :catch_changes  => true)
        else
          shell('sleep 5') # Give services time to stop
          apply_manifest(pp, :catch_changes  => true)
        end
      end

      describe service('sensu-client') do
        it { is_expected.not_to be_running }
        it { is_expected.not_to be_enabled }
      end
    end # no client
  end # sensu
end
