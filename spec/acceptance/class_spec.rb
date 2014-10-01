require 'spec_helper_acceptance'

describe 'sensu class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'sensu' do
    context 'ensure => present' do
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
        class { 'sensu':
          server                   => true,
          api                      => true,
          purge_config             => true,
          rabbitmq_password        => 'secret',
          rabbitmq_host            => 'localhost',
        }
        EOS

        # Run it twice and test for idempotency
        expect(apply_manifest(pp).exit_code).to_not eq(1)
        expect(apply_manifest(pp).exit_code).to eq(0)
      end
      it 'should start the API' do
        shell('curl localhost:4567/info') do |curl|
          expect(curl.stdout).to include 'sensu', 'version'
        end
      end
    end
  end
end