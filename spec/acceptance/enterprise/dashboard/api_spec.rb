require 'spec_helper_acceptance'

describe 'sensu::enterprise::dashboard::api', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'sensu' do
    context 'default' do
      break unless ENV['SE_USER'] && ENV['SE_PASS']

      it 'should work with no errors' do
        pp = <<-EOS
        class { 'sensu':
          enterprise_dashboard => true,
          enterprise_user      => #{ENV['SE_USER']},
          enterprise_pass      => #{ENV['SE_PASS']},
        }

        sensu::enterprise::dashboard::api { 'sensu.example.com':
          datacenter => 'example-dc',
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe service('sensu-enterprise-dashboard') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end

      describe file('/etc/sensu/dashboard.json') do
        it { is_expected.to be_file }
        its(:content) { should match /name.*?example-dc/ }
        its(:content) { should match /host.*?sensu\.example\.com/ }
      end
    end
  end
end
