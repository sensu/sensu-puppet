require 'spec_helper'

describe 'sensu::backend', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      context 'with default values for all parameters' do
        it { should compile.with_all_deps }

        it { should create_class('sensu::backend') }
        it { should contain_class('sensu') }
        it { should_not contain_class('sensu::agent') }
        it { should contain_class('sensu::ssl').that_comes_before('Sensu_configure[puppet]') }
        it { should contain_class('sensu::backend::default_resources') }

        it {
          should contain_package('sensu-go-cli').with({
            'ensure'  => 'installed',
            'name'    => 'sensu-go-cli',
            'require' => platforms[facts[:osfamily]][:package_require],
          })
        }

        it {
          should contain_sensu_api_validator('sensu').with({
            'sensu_api_server' => 'test.example.com',
            'sensu_api_port'   => 8080,
            'use_ssl'          => 'true',
            'require'          => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_sensu_configure('puppet').with({
            'url'                 => 'https://test.example.com:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'bootstrap_password'  => 'P@ssw0rd!',
            'trusted_ca_file'     => '/etc/sensu/ssl/ca.crt',
          })
        }

        it {
          should contain_sensu_user('admin').with({
            'ensure'        => 'present',
            'password'      => 'P@ssw0rd!',
            'old_password'  => nil,
            'groups'        => ['cluster-admins'],
            'disabled'      => 'false',
            'configure'     => 'true',
            'configure_url' => 'https://test.example.com:8080',
          })
        }

        it { should_not contain_file('sensu_license') }
        it { should_not contain_exec('sensu-add-license') }

        it {
          should contain_file('sensu_ssl_cert').with({
            'ensure'    => 'file',
            'path'      => '/etc/sensu/ssl/cert.pem',
            'source'    => '/dne/cert.pem',
            'owner'     => 'sensu',
            'group'     => 'sensu',
            'mode'      => '0644',
            'show_diff' => 'false',
            'notify'    => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_file('sensu_ssl_key').with({
            'ensure'    => 'file',
            'path'      => '/etc/sensu/ssl/key.pem',
            'source'    => '/dne/key.pem',
            'owner'     => 'sensu',
            'group'     => 'sensu',
            'mode'      => '0600',
            'show_diff' => 'false',
            'notify'    => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_package('sensu-go-backend').with({
            'ensure'  => 'installed',
            'name'    => 'sensu-go-backend',
            'require' => platforms[facts[:osfamily]][:package_require],
          })
        }

        it {
          should contain_file('sensu_backend_state_dir').with({
            'ensure'  => 'directory',
            'path'    => '/var/lib/sensu/sensu-backend',
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0750',
            'require' => 'Package[sensu-go-backend]',
            'before'  => 'Service[sensu-backend]',
          })
        }

        backend_content = <<-END.gsub(/^\s+\|/, '')
          |---
          |state-dir: "/var/lib/sensu/sensu-backend"
          |api-url: https://test.example.com:8080
          |cert-file: "/etc/sensu/ssl/cert.pem"
          |key-file: "/etc/sensu/ssl/key.pem"
          |trusted-ca-file: "/etc/sensu/ssl/ca.crt"
        END

        it {
          should contain_file('sensu_backend_config').with({
            'ensure'    => 'file',
            'path'      => '/etc/sensu/backend.yml',
            'content'   => backend_content,
            'show_diff' => 'true',
            'require'   => 'Package[sensu-go-backend]',
            'notify'    => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_service('sensu-backend').with({
            'ensure'    => 'running',
            'enable'    => true,
            'name'      => 'sensu-backend',
            'subscribe' => 'Class[Sensu::Ssl]',
          })
        }
      end

      context 'with use_ssl => false' do
        let(:pre_condition) do
          "class { 'sensu': use_ssl => false }"
        end

        it {
          should contain_sensu_api_validator('sensu').with({
            'sensu_api_server' => 'test.example.com',
            'sensu_api_port'   => 8080,
            'use_ssl'          => 'false',
            'require'          => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_sensu_configure('puppet').with({
            'url'                 => 'http://test.example.com:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'bootstrap_password'  => 'P@ssw0rd!',
            'trusted_ca_file'     => 'absent',
          })
        }

        it { should_not contain_file('sensu_ssl_cert') }
        it { should_not contain_file('sensu_ssl_key') }

        backend_content = <<-END.gsub(/^\s+\|/, '')
          |---
          |state-dir: "/var/lib/sensu/sensu-backend"
          |api-url: http://test.example.com:8080
        END

        it {
          should contain_file('sensu_backend_config').with({
            'ensure'  => 'file',
            'path'    => '/etc/sensu/backend.yml',
            'content' => backend_content,
            'require' => 'Package[sensu-go-backend]',
            'notify'  => 'Service[sensu-backend]',
          })
        }

        it { should contain_service('sensu-backend').without_notify }
      end

      context 'with show_diff => false' do
        let(:params) {{ :show_diff => false }}
        it { should contain_file('sensu_backend_config').with_show_diff('false') }
      end

      context 'with manage_repo => false' do
        let(:pre_condition) do
          "class { 'sensu': manage_repo => false }"
        end
        it { should contain_package('sensu-go-cli').without_require }
        it { should contain_package('sensu-go-backend').without_require }
      end

      context 'with include_default_resources => false' do
        let(:params) {{ :include_default_resources => false }}
        it { should_not contain_class('sensu::backend::default_resources') }
      end

      context 'with license_source defined' do
        let(:params) {{ :license_source => 'puppet:///modules/site_sensu/license.json' }}
        it {
          should contain_file('sensu_license').with({
            'ensure'    => 'file',
            'path'      => '/etc/sensu/license.json',
            'source'    => 'puppet:///modules/site_sensu/license.json',
            'content'   => nil,
            'owner'     => 'sensu',
            'group'     => 'sensu',
            'mode'      => '0600',
            'show_diff' => 'false',
            'notify'    => 'Exec[sensu-add-license]',
          })
        }
        it {
          should contain_exec('sensu-add-license').with({
            'path'        => '/usr/bin:/bin:/usr/sbin:/sbin',
            'command'     => 'sensuctl create --file /etc/sensu/license.json',
            'refreshonly' => 'true',
            'require'     => 'Sensu_configure[puppet]',
          })
        }
      end

      context 'with license_content defined' do
        let(:params) {{ :license_content => '{ }' }}
        it {
          should contain_file('sensu_license').with({
            'ensure'    => 'file',
            'path'      => '/etc/sensu/license.json',
            'source'    => nil,
            'content'   => '{ }',
            'owner'     => 'sensu',
            'group'     => 'sensu',
            'mode'      => '0600',
            'show_diff' => 'false',
            'notify'    => 'Exec[sensu-add-license]',
          })
        }
        it {
          should contain_exec('sensu-add-license').with({
            'path'        => '/usr/bin:/bin:/usr/sbin:/sbin',
            'command'     => 'sensuctl create --file /etc/sensu/license.json',
            'refreshonly' => 'true',
            'require'     => 'Sensu_configure[puppet]',
          })
        }
      end

      context 'both license_content and license_source' do
        let(:params) {{ :license_source => '/dne', :license_content => '{ }' }}
        it 'should fail' do
           is_expected.to compile.and_raise_error(/Do not define both license_source and license_content/)
        end
      end
    end
  end
end

