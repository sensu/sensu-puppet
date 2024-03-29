require 'spec_helper'

describe 'sensu::api', :type => :class do
  # Only test 1 OS to speed up tests when behavior does not vary based on OS facts
  on_supported_os({
    supported_os: [{ 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['7'] }]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }

      context 'with default values for all parameters' do
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
        end

        it { should create_class('sensu::api') }
        it { should contain_class('sensu') }

        it {
          should contain_sensu_api_config('sensu').with({
            'url'                 => 'https://test.example.com:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'validate_namespaces' => 'true',
          })
        }

        it {
          should contain_sensu_api_validator('sensu').with({
            'sensu_api_server' => 'test.example.com',
            'sensu_api_port'   => 8080,
            'use_ssl'          => 'true',
          })
        }

      end

      context 'when validate_api => false' do
        let(:pre_condition) do
          <<-PP
            class { 'sensu':
              validate_api => false,
            }
          PP
        end

        it { is_expected.not_to contain_sensu_api_validator('sensu') }
      end
    end
  end
end

