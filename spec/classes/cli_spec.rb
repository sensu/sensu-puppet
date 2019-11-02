require 'spec_helper'

describe 'sensu::cli', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      context 'with default values for all parameters' do
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
          it { should contain_class('sensu::ssl').that_comes_before('Sensu_configure[puppet]') }
        end

        it { should create_class('sensu::cli') }
        it { should contain_class('sensu') }

        it {
          should contain_package('sensu-go-cli').with({
            'ensure'  => 'installed',
            'name'    => 'sensu-go-cli',
            'require' => platforms[facts[:osfamily]][:package_require],
          })
        }

        it { should contain_sensuctl_config('sensu').without_chunk_size }

        it {
          should contain_sensu_configure('puppet').with({
            'url'                 => 'https://test.example.com:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'bootstrap_password'  => 'P@ssw0rd!',
            'trusted_ca_file'     => platforms[facts[:osfamily]][:ca_path],
          })
        }

      end

      context 'with use_ssl => false' do
        let(:pre_condition) do
          "class { 'sensu': use_ssl => false }"
        end
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
        end
        it {
          should contain_sensu_configure('puppet').with({
            'url'                 => 'http://test.example.com:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'bootstrap_password'  => 'P@ssw0rd!',
            'trusted_ca_file'     => 'absent',
          })
        }
      end

      context 'with manage_repo => false' do
        let(:pre_condition) do
          "class { 'sensu': manage_repo => false }"
        end
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
        end
        it { should contain_package('sensu-go-cli').without_require }
      end
    end
  end
end

