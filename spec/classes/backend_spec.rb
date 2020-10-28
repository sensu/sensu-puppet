require 'spec_helper'

describe 'sensu::backend', :type => :class do
  on_supported_os.each do |os, facts|
    # Windows is not supported for backend
    if facts[:os]['family'] == 'windows'
      next
    end
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      context 'with default values for all parameters' do
        it { should compile.with_all_deps }

        it { should create_class('sensu::backend') }
        it { should contain_class('sensu') }
        it { should contain_class('sensu::common')}
        it { should contain_class('sensu::cli') }
        it { should_not contain_class('sensu::agent') }
        it { should contain_class('sensu::ssl').that_comes_before('Sensuctl_configure[puppet]') }
        it { should contain_class('sensu::backend::default_resources') }
        it { should contain_class('sensu::backend::agent_resources') }
        it { should_not contain_class('sensu::backend::datastore::postgresql') }

        context 'on systemd host', if: Puppet.version.to_s =~ %r{^5} do
          let(:facts) { facts.merge({:service_provider => 'systemd'}) }
          it { should contain_package('sensu-go-backend').that_notifies('Class[systemd::systemctl::daemon_reload]') }
          it { should contain_class('systemd::systemctl::daemon_reload').that_comes_before('Service[sensu-backend]') }
        end
        it { should_not contain_package('sensu-go-backend').that_notifies('Class[systemd::systemctl::daemon_reload]') }
        it { should_not contain_class('systemd::systemctl::daemon_reload').that_comes_before('Service[sensu-backend]') }

        it { should have_sensu_user_resource_count(3) }
        it {
          should contain_sensu_user('admin').with({
            'ensure'                    => 'present',
            'password'                  => 'P@ssw0rd!',
            'groups'                    => ['cluster-admins'],
            'disabled'                  => 'false',
            'configure'                 => 'true',
            'configure_url'             => 'https://test.example.com:8080',
            'configure_trusted_ca_file' => '/etc/sensu/ssl/ca.crt',
            'provider'                  => 'sensu_api',
            'before'                    => 'Sensuctl_configure[puppet]',
          })
        }
        it {
          should contain_sensu_user('agent').with({
            'ensure'       => 'present',
            'disabled'     => 'false',
            'password'     => 'P@ssw0rd!',
            'groups'       => ['system:agents'],
          })
        }

        it { should contain_sensu_tessen('puppet').with_ensure('present') }

        it { should_not contain_file('sensu_license') }
        it { should_not contain_sensu_license('puppet') }

        it {
          should contain_file('sensu_ssl_cert').with({
            'ensure'    => 'file',
            'path'      => '/etc/sensu/ssl/cert.pem',
            'source'    => '/dne/cert.pem',
            'content'   => nil,
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
            'content'   => nil,
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
            'notify'  => 'Service[sensu-backend]',
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
            'owner'     => 'sensu',
            'group'     => 'sensu',
            'mode'      => '0640',
            'show_diff' => 'true',
            'require'   => 'Package[sensu-go-backend]',
            'notify'    => 'Service[sensu-backend]',
          })
        }

        let(:service_env_vars_content) do
          <<-END.gsub(/^\s+\|/, '')
            |# This file is being maintained by Puppet.
            |# DO NOT EDIT
          END
        end

        if platforms[facts[:osfamily]][:backend_service_env_vars_file]
          it {
            should contain_file('sensu-backend_env_vars').with({
              'ensure'  => 'file',
              'path'    => platforms[facts[:osfamily]][:backend_service_env_vars_file],
              'content' => service_env_vars_content,
              'owner'   => platforms[facts[:osfamily]][:user],
              'group'   => platforms[facts[:osfamily]][:group],
              'mode'    => '0640',
              'require' => 'Package[sensu-go-backend]',
              'notify'  => 'Service[sensu-backend]',
            })
          }
        else
          it { should_not contain_file('sensu-backend_env_vars') }
        end

        context 'systemd systems deploy dropin', if: facts[:kernel] == 'Linux' do
          let(:facts) { facts.merge({:service_provider => 'systemd'}) }
          it {
            should contain_systemd__dropin_file('sensu-backend-start.conf').with({
              'unit'    => 'sensu-backend.service',
              'content' => %r{ExecStart=/usr/sbin/sensu-backend start -c /etc/sensu/backend.yml},
              'notify'  => 'Service[sensu-backend]',
            })
          }
        end
        it { should_not contain_systemd__dropin_file('sensu-backend-start.conf') }

        it {
          should contain_service('sensu-backend').with({
            'ensure'    => 'running',
            'enable'    => true,
            'name'      => 'sensu-backend',
            'subscribe' => 'Class[Sensu::Ssl]',
          })
        }
      end

      context 'when puppet_hostcert undefined' do
        let(:facts) { facts.merge(puppet_hostcert: nil) }
        it { should compile.and_raise_error(/ssl_cert_source or ssl_cert_content must be defined/) }
      end

      context 'when puppet_hostprivkey undefined' do
        let(:facts) { facts.merge(puppet_hostprivkey: nil) }
        it { should compile.and_raise_error(/ssl_key_source or ssl_key_content must be defined/) }
      end

      context 'when ssl_cert_content defined' do
        let(:params) { { ssl_cert_content: 'foo' } }
        it { should contain_file('sensu_ssl_cert').with_content('foo').without_source }
      end

      context 'when ssl_key_content defined' do
        let(:params) { { ssl_key_content: 'foo' } }
        it { should contain_file('sensu_ssl_key').with_content('foo').without_source }
      end

      context 'with use_ssl => false' do
        let(:pre_condition) do
          "class { 'sensu': use_ssl => false }"
        end

        it { should compile.with_all_deps }
        it { should_not contain_file('sensu_ssl_cert') }
        it { should_not contain_file('sensu_ssl_key') }

        it {
          should contain_sensu_user('admin').with({
            'ensure'                    => 'present',
            'password'                  => 'P@ssw0rd!',
            'groups'                    => ['cluster-admins'],
            'disabled'                  => 'false',
            'configure'                 => 'true',
            'configure_url'             => 'http://test.example.com:8080',
            'configure_trusted_ca_file' => 'absent',
            'provider'                  => 'sensu_api',
            'before'                    => 'Sensuctl_configure[puppet]',
          })
        }

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

        it {
          should contain_exec('sensu-backend init').with({
            'path'        => '/usr/bin:/bin:/usr/sbin:/sbin',
            'environment' => [
              'SENSU_BACKEND_CLUSTER_ADMIN_USERNAME=admin',
              'SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD=P@ssw0rd!',
            ],
            'returns'     => [0, 3],
            'unless'      => 'sensu-backend init ; [ $? -eq 3 ] && exit 0 || exit 1',
            'require'     => 'Sensu_api_validator[sensu]',
            'before'      => [
              'Sensu_user[admin]',
              'Sensuctl_configure[puppet]',
            ],
          })
        }

        context 'when puppet_hostcert undefined' do
          let(:facts) { facts.merge(puppet_hostcert: nil) }
          it { should compile.with_all_deps }
        end

        context 'when puppet_hostprivkey undefined' do
          let(:facts) { facts.merge(puppet_hostprivkey: nil) }
          it { should compile.with_all_deps }
        end
      end

      context 'with show_diff => false' do
        let(:params) {{ :show_diff => false }}
        it { should contain_file('sensu_backend_config').with_show_diff('false') }
      end

      context 'with manage_repo => false' do
        let(:pre_condition) do
          "class { 'sensu': manage_repo => false }"
        end
        it { should compile.with_all_deps }
        it { should contain_package('sensu-go-backend').without_require }
      end

      context 'with include_default_resources => false' do
        let(:params) {{ :include_default_resources => false }}
        it { should compile.with_all_deps }
        it { should_not contain_class('sensu::backend::default_resources') }
      end

      context 'with include_agent_resources => false' do
        let(:params) {{ :include_agent_resources => false }}
        it { should compile.with_all_deps }
        it { should_not contain_class('sensu::backend::agent_resources') }
      end

      context 'with manage_agent_user => false' do
        let(:params) {{ :manage_agent_user => false }}
        it { should compile.with_all_deps }
        it { should_not contain_sensu_user('agent') }
      end

      context 'with agent_user_disabled => true' do
        let(:params) {{ :agent_user_disabled => true }}
        it { should compile.with_all_deps }
        it { should contain_sensu_user('agent').with_disabled('true') }
      end

      context 'with license_source defined' do
        let(:params) {{ :license_source => 'puppet:///modules/site_sensu/license.json' }}
        it { should compile.with_all_deps }
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
            'notify'    => 'Sensu_license[puppet]',
          })
        }
        it {
          should contain_sensu_license('puppet').with({
            'ensure' => 'present',
            'file'   => '/etc/sensu/license.json',
          })
        }
      end

      context 'with license_content defined' do
        let(:params) {{ :license_content => '{ }' }}
        it { should compile.with_all_deps }
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
            'notify'    => 'Sensu_license[puppet]',
          })
        }
        it {
          should contain_sensu_license('puppet').with({
            'ensure' => 'present',
            'file'   => '/etc/sensu/license.json',
          })
        }
      end

      context 'both license_content and license_source' do
        let(:params) {{ :license_source => '/dne', :license_content => '{ }' }}
        it 'should fail' do
           is_expected.to compile.and_raise_error(/Do not define both license_source and license_content/)
        end
      end

      context 'tessen_ensure => absent' do
        let(:params) {{ :tessen_ensure => 'absent' }}
        it { should compile.with_all_deps }
        it { is_expected.to contain_sensu_tessen('puppet').with_ensure('absent') }
      end

      context 'manage_tessen => false' do
        let(:params) {{ :manage_tessen => false }}
        it { should compile.with_all_deps }
        it { is_expected.not_to contain_sensu_tessen('puppet') }
      end

      context 'datastore => postgresql' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          EOS
        end
        let(:params) {{ :datastore => 'postgresql' }}
        it { should compile.with_all_deps }
        it { should contain_class('sensu::backend::datastore::postgresql') }
      end

      context 'with service_env_vars defined' do
        let(:params) {{ :service_env_vars => { 'SENSU_BACKEND_AGENT_PORT' => '9081' } }}
        let(:service_env_vars_content) do
          <<-END.gsub(/^\s+\|/, '')
            |# This file is being maintained by Puppet.
            |# DO NOT EDIT
            |SENSU_BACKEND_AGENT_PORT="9081"
          END
        end
        if platforms[facts[:osfamily]][:backend_service_env_vars_file]
          it { should contain_file('sensu-backend_env_vars').with_content(service_env_vars_content) }
        end
      end
    end
  end
end

