require 'spec_helper'

describe 'sensu::agent', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'localhost' }
      describe 'with default values for all parameters' do
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
        end

        it { should contain_class('sensu')}
        it { should contain_class('sensu::common')}
        it { should contain_class('sensu::api')}
        it { should contain_class('sensu::agent')}

        if facts[:os]['family'] == 'windows'
          sensu_agent_exe = "C:\\Program Files\\sensu\\sensu-agent\\bin\\sensu-agent.exe"
          it {
            should contain_exec('install-agent-service').with({
              'command' => "C:\\windows\\system32\\cmd.exe /c \"\"#{sensu_agent_exe}\" service install --config-file \"#{platforms[facts[:osfamily]][:agent_config_path]}\" --log-file \"#{platforms[facts[:osfamily]][:log_file]}\"\"",
              'unless'  => 'C:\\windows\\system32\\sc.exe query SensuAgent',
              'before'  => 'Service[sensu-agent]',
              'require' => [
                'Package[sensu-go-agent]',
                'File[sensu_agent_config]',
              ],
            })
          }
        else
          it { should_not contain_exec('install-agent-service') }
        end
        it { should_not contain_archive('sensu-go-agent.msi') }

        context 'on systemd host', if: (facts[:kernel] == 'Linux' && Puppet.version.to_s =~ %r{^5}) do
          let(:facts) { facts.merge({:service_provider => 'systemd'}) }
          it { should contain_package('sensu-go-agent').that_notifies('Class[systemd::systemctl::daemon_reload]') }
          it { should contain_class('systemd::systemctl::daemon_reload').that_comes_before('Service[sensu-agent]') }
        end
        it { should_not contain_package('sensu-go-agent').that_notifies('Class[systemd::systemctl::daemon_reload]') }
        it { should_not contain_class('systemd::systemctl::daemon_reload').that_comes_before('Service[sensu-agent]') }

        it {
          should contain_sensu_agent_entity_setup('puppet').with({
            'url'       => 'https://localhost:8080',
            'username'  => 'puppet-agent_entity_config',
            'password'  => 'P@ssw0rd!',
          })
        }

        it {
          should contain_package('sensu-go-agent').with({
            'ensure'   => 'installed',
            'name'     => platforms[facts[:osfamily]][:agent_package_name],
            'source'   => nil,
            'provider' => platforms[facts[:osfamily]][:package_provider],
            'before'   => 'File[sensu_etc_dir]',
            'require'  => platforms[facts[:osfamily]][:package_require],
            'notify'   => 'Service[sensu-agent]',
          })
        }

        it {
          should contain_datacat_collector('sensu_agent_config').with({
            'template'        => 'sensu/agent.yml.erb',
            'template_body'   => %r{data.to_yaml},
            'target_resource' => 'File[sensu_agent_config]',
            'target_field'    => 'content',
          })
        }

        it {
          should contain_datacat_fragment('sensu_agent_config-main').with({
            'target' => 'sensu_agent_config',
            'data'   => {
              'backend-url'     => ['wss://localhost:8081'],
              'name'            => 'localhost',
              'namespace'       => 'default',
              'redact'          => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret'],
              'password'        => 'P@ssw0rd!',
              'trusted-ca-file' => platforms[facts[:osfamily]][:ca_path],
            },
            'order'  => '01',
          })
        }

        it {
          should contain_file('sensu_agent_config').with({
            'ensure'  => 'file',
            'path'    => platforms[facts[:osfamily]][:agent_config_path],
            'owner'   => platforms[facts[:osfamily]][:user],
            'group'   => platforms[facts[:osfamily]][:group],
            'mode'    => platforms[facts[:osfamily]][:agent_config_mode],
            'require' => 'Package[sensu-go-agent]',
            'notify'  => 'Service[sensu-agent]',
          })
        }

        let(:service_env_vars_content) do
          <<-END.gsub(/^\s+\|/, '')
            |# This file is being maintained by Puppet.
            |# DO NOT EDIT
          END
        end

        if platforms[facts[:osfamily]][:agent_service_env_vars_file]
          it {
            should contain_file('sensu-agent_env_vars').with({
              'ensure'  => 'file',
              'path'    => platforms[facts[:osfamily]][:agent_service_env_vars_file],
              'content' => service_env_vars_content,
              'owner'   => platforms[facts[:osfamily]][:user],
              'group'   => platforms[facts[:osfamily]][:group],
              'mode'    => platforms[facts[:osfamily]][:agent_config_mode],
              'require' => 'Package[sensu-go-agent]',
              'notify'  => 'Service[sensu-agent]',
            })
          }
        else
          it { should_not contain_file('sensu-agent_env_vars') }
        end

        context 'systemd systems deploy dropin', if: facts[:kernel] == 'Linux' do
          let(:facts) { facts.merge({:service_provider => 'systemd'}) }
          it {
            should contain_systemd__dropin_file('sensu-agent-start.conf').with({
              'unit'    => 'sensu-agent.service',
              'content' => %r{ExecStart=/usr/sbin/sensu-agent start -c #{platforms[facts[:osfamily]][:agent_config_path]}},
              'notify'  => 'Service[sensu-agent]',
            })
          }
        end
        it { should_not contain_systemd__dropin_file('sensu-agent-start.conf') }

        it {
          should contain_service('sensu-agent').with({
            'ensure'    => 'running',
            'enable'    => true,
            'name'      => platforms[facts[:osfamily]][:agent_service_name],
            'subscribe' => 'Class[Sensu::Ssl]',
          })
        }

        it {
          should contain_sensu_agent_entity_validator('localhost').with({
            'namespace' => 'default',
            'provider'  => 'sensu_api',
          })
        }
      end

      context 'when package_source defined as URL' do
        let(:params) {{ package_source: 'https://foo/sensu-go-agent.msi' }}
        if facts[:os]['family'] == 'windows'
          it {
            should contain_archive('sensu-go-agent.msi').with({
              'source' => 'https://foo/sensu-go-agent.msi',
              'path'   => 'C:\\\\sensu-go-agent.msi',
              'extract'=> 'false',
              'cleanup'=> 'false',
              'before' => 'Package[sensu-go-agent]',
            })
          }
          it { should contain_package('sensu-go-agent').with_source('C:\\\\sensu-go-agent.msi') }
          it { should contain_package('sensu-go-agent').without_provider }
        else
          it { should_not contain_archive('sensu-go-agent.msi') }
          it { should contain_package('sensu-go-agent').without_source }
        end
      end

      context 'when package_source defined as puppet' do
        let(:params) {{ package_source: 'puppet:///modules/profile/sensu-go-agent.msi' }}
        if facts[:os]['family'] == 'windows'
          it {
            should contain_file('sensu-go-agent.msi').with({
              'ensure' => 'file',
              'source' => 'puppet:///modules/profile/sensu-go-agent.msi',
              'path'   => 'C:\\\\sensu-go-agent.msi',
              'before' => 'Package[sensu-go-agent]',
            })
          }
          it { should contain_package('sensu-go-agent').with_source('C:\\\\sensu-go-agent.msi') }
          it { should contain_package('sensu-go-agent').without_provider }
        else
          it { should_not contain_archive('sensu-go-agent.msi') }
          it { should contain_package('sensu-go-agent').without_source }
        end
      end

      context 'when package_source is local' do
        let(:params) {{ package_source: 'C:\\sensu-go-agent.msi' }}
        it { should_not contain_archive('sensu-go-agent.msi') }
        if facts[:os]['family'] == 'windows'
          it { should contain_package('sensu-go-agent').with_source('C:\\sensu-go-agent.msi') }
          it { should contain_package('sensu-go-agent').without_provider }
        else
          it { should contain_package('sensu-go-agent').without_source }
        end
      end


      context 'when agent_entity_config_password is defined' do
        let(:pre_condition) do
          "class { 'sensu': agent_entity_config_password => 'password' }"
        end

        it {
          should contain_sensu_agent_entity_setup('puppet').with({
            'url'       => 'https://localhost:8080',
            'username'  => 'puppet-agent_entity_config',
            'password'  => 'password',
          })
        }
      end

      context 'with use_ssl => false' do
        let(:pre_condition) do
          "class { 'sensu': use_ssl => false }"
        end

        it {
          should contain_sensu_agent_entity_setup('puppet').with({
            'url'       => 'http://localhost:8080',
            'username'  => 'puppet-agent_entity_config',
            'password'  => 'P@ssw0rd!',
          })
        }
        it {
          should contain_datacat_fragment('sensu_agent_config-main').with({
            'target' => 'sensu_agent_config',
            'data'   => {
              'backend-url' => ['ws://localhost:8081'],
              'name'        => 'localhost',
              'namespace'   => 'default',
              'redact'      => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret'],
              'password'    => 'P@ssw0rd!',
            },
          })
        }

        it { should contain_service('sensu-agent').without_notify }
      end

      context 'with agent configs defined' do
        let(:params) do
          {
            entity_name: 'hostname',
            subscriptions: ['linux','base'],
            annotations: { 'foo' => 'bar' },
            labels: { 'bar' => 'baz' },
            namespace: 'qa',
            redact: ['secret'],
          }
        end

        it {
          should contain_datacat_fragment('sensu_agent_config-main').with({
            'target' => 'sensu_agent_config',
            'data'   => {
              'backend-url'     => ['wss://localhost:8081'],
              'name'            => 'hostname',
              'subscriptions'   => ['linux','base'],
              'annotations'     => {'foo' => 'bar'},
              'labels'          => {'bar' => 'baz'},
              'namespace'       => 'qa',
              'redact'          => ['secret'],
              'password'        => 'P@ssw0rd!',
              'trusted-ca-file' => platforms[facts[:osfamily]][:ca_path],
            },
          })
        }
        it { is_expected.to contain_sensu__agent__subscription('linux') }
        it { is_expected.to contain_sensu__agent__subscription('base') }
      end

      context 'with agent configs defined and config_hash' do
        let(:params) do
          {
            entity_name: 'hostname',
            subscriptions: ['linux','base'],
            annotations: { 'foo' => 'bar' },
            labels: { 'bar' => 'baz' },
            namespace: 'qa',
            config_hash: {
              'subscriptions' => ['windows'],
              'namespace' => 'default',
            }
          }
        end

        it {
          should contain_datacat_fragment('sensu_agent_config-main').with({
            'target' => 'sensu_agent_config',
            'data'   => {
              'backend-url'     => ['wss://localhost:8081'],
              'name'            => 'hostname',
              'subscriptions'   => ['windows'],
              'annotations'     => {'foo' => 'bar'},
              'labels'          => {'bar' => 'baz'},
              'namespace'       => 'default',
              'redact'          => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret'],
              'password'        => 'P@ssw0rd!',
              'trusted-ca-file' => platforms[facts[:osfamily]][:ca_path],
            },
          })
        }
        it { is_expected.to contain_sensu__agent__subscription('windows') }
      end

      context 'with show_diff => false' do
        let(:params) {{ :show_diff => false }}
        it { should contain_file('sensu_agent_config').with_show_diff('false') }
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
        it { should contain_package('sensu-go-agent').without_require }
      end

      context 'with service_env_vars defined' do
        let(:params) {{ :service_env_vars => { 'SENSU_API_PORT' => '4041' } }}
        let(:service_env_vars_content) do
          <<-END.gsub(/^\s+\|/, '')
            |# This file is being maintained by Puppet.
            |# DO NOT EDIT
            |SENSU_API_PORT="4041"
          END
        end

        if platforms[facts[:osfamily]][:agent_service_env_vars_file]
          it { should contain_file('sensu-agent_env_vars').with_content(service_env_vars_content) }
        end
        if facts[:os]['family'] == 'windows'
          it {
            should contain_windows_env('SENSU_API_PORT').with({
              :ensure     => 'present',
              :value      => '4041',
              :mergemode  => 'clobber',
              :notify     => 'Service[sensu-agent]',
            })
          }
        else
          it { should_not contain_windows_env('sensu_api_host') }
        end
      end

      context 'labels and annotations validations' do
        invalid_combinations = {
          'labels'      => [1, true, ['foo'], {'foo' => 'bar'}],
          'annotations' => [1, true, ['foo'], {'foo' => 'bar'}],
        }
        invalid_combinations.each_pair do |param, values|
          values.each do |value|
            context "#{param} invalid for #{value.class}" do
              let(:params) { { param => { 'key' => value } } }
              it { is_expected.to compile.and_raise_error(/expects a String value/) }
            end
          end
        end
      end

      # Test various backend values
      [
        ['ws://localhost:8081'],
        ['wss://localhost:8081'],
        ['localhost:8081'],
        ['127.0.0.1:8081'],
        ['ws://127.0.0.1:8081'],
        ['wss://127.0.0.1:8081'],
        ['test.example.com:8081'],
        ['ws://test.example.com:8081'],
        ['wss://test.example.com:8081'],
      ].each do |backends|
        context "with backends => #{backends}" do
          let(:params) { { :backends => backends } }

          # Unknown bug in rspec-puppet fails to compile windows paths
          # when they are used for file source of sensu_ssl_ca, issue with windows mocking
          # https://github.com/rodjek/rspec-puppet/issues/750
          if facts[:os]['family'] != 'windows'
            it { should compile.with_all_deps }
          end

          if backends[0] =~ /(ws|wss):\/\//
            backend = backends[0]
          else
            backend = "wss://#{backends[0]}"
          end

          it {
            should contain_datacat_fragment('sensu_agent_config-main').with({
              'target' => 'sensu_agent_config',
              'data'   => {
                'backend-url'     => [backend],
                'name'            => 'localhost',
                'namespace'       => 'default',
                'redact'          => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret'],
                'password'        => 'P@ssw0rd!',
                'trusted-ca-file' => platforms[facts[:osfamily]][:ca_path],
              },
            })
          }
        end
      end
    end
  end
end

