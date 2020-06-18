require 'spec_helper'

describe 'sensu::cli', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      let(:install_source_param) do
        'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.14.1/sensu-go_5.14.1_windows_amd64.zip'
      end
      let(:default_params) do
        if facts[:osfamily] == 'windows'
          { :install_source => install_source_param }
        else
          {}
        end
      end
      let(:params) { default_params }

      context 'with default values for all parameters' do
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
          it { should contain_class('sensu::ssl').that_comes_before('Sensuctl_configure[puppet]') }
        end

        it { should create_class('sensu::cli') }
        it { should contain_class('sensu') }
        it { should contain_class('sensu::common')}

        if facts[:os]['family'] == 'windows'
          it { should contain_file('C:\\Program Files\\Sensu').with_ensure('directory') }
          it {
            should contain_archive('sensu-go-cli.zip').with({
              'path'         => 'C:\\Program Files\\Sensu\\sensu-go-cli.zip',
              'source'       => install_source_param,
              'extract'      => 'true',
              'extract_path' => 'C:\\Program Files\\Sensu',
              'creates'      => 'C:\\Program Files\\Sensu\\sensuctl.exe',
              'cleanup'      => 'false',
              'require'      => 'File[C:\\Program Files\\Sensu]',
            })
          }
          it {
            should contain_windows_env('sensuctl-path').with({
              'ensure'    => 'present',
              'variable'  => 'PATH',
              'value'     => 'C:\\Program Files\\Sensu',
              'mergemode' => 'append',
              'require'   => 'Archive[sensu-go-cli.zip]',
            })
          }
          it { should_not contain_package('sensu-go-cli') }
        else
          it { should_not contain_archive('sensu-go-cli.zip') }
          it { should_not contain_windows_env('sensuctl-path') }
          it {
            should contain_package('sensu-go-cli').with({
              'ensure'  => 'installed',
              'name'    => 'sensu-go-cli',
              'require' => platforms[facts[:osfamily]][:package_require],
            })
          }
        end

        it { should contain_sensuctl_config('sensu').without_chunk_size }
        it { should contain_sensuctl_config('sensu').with_validate_namespaces('true') }

        it {
          should contain_sensuctl_configure('puppet').with({
            'url'                 => 'https://test.example.com:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'trusted_ca_file'     => platforms[facts[:osfamily]][:ca_path],
            'config_format'       => nil,
            'config_namespace'    => nil,
          })
        }

      end

      context 'when install_source is puppet URL', if: facts[:osfamily] == 'windows' do
        let(:install_source_param) { 'puppet:///sensu-go-cli.zip' }
        it { should contain_archive('sensu-go-cli.zip').with_source(install_source_param) }
      end

      context 'when install_source is file', if: facts[:osfamily] == 'windows' do
        let(:install_source_param) { 'file:\\C:\\sensu-go-cli.zip' }
        it { should contain_archive('sensu-go-cli.zip').with_source(install_source_param) }
      end

      context 'when install_source is not set' do
        let(:params) { {} }
        if facts[:osfamily] == 'windows'
          it { should compile.and_raise_error(/install_source is required for Windows/) }
        else
          it { should compile.with_all_deps }
        end
      end

      context 'with validate_namespaces => false' do
        let(:pre_condition) do
          "class { 'sensu': validate_namespaces => false }"
        end
        it { should contain_sensuctl_config('sensu').with_validate_namespaces('false') }
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
          should contain_sensuctl_configure('puppet').with({
            'url'                 => 'http://test.example.com:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'trusted_ca_file'     => 'absent',
            'config_format'       => nil,
            'config_namespace'    => nil,
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
          it { should contain_package('sensu-go-cli').without_require }
        end
      end
    end
  end
end

