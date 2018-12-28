require 'spec_helper'

describe 'sensu::backend', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        it { should compile.with_all_deps }

        it { should contain_class('sensu::backend')}

        it {
          should contain_package('sensu-go-cli').with({
            'ensure'  => 'installed',
            'name'    => 'sensu-go-cli',
            'require' => 'Class[Sensu::Repo]',
          })
        }

        it {
          should contain_sensu_api_validator('sensu').with({
            'sensu_api_server' => '127.0.0.1',
            'sensu_api_port'   => 8080,
            'use_ssl'          => 'false',
            'require'          => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_sensu_configure('puppet').with({
            'url'                 => 'http://127.0.0.1:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'bootstrap_password'  => 'P@ssw0rd!',
          })
        }

        it {
          should contain_package('sensu-go-backend').with({
            'ensure'  => 'installed',
            'name'    => 'sensu-go-backend',
            'require' => 'Class[Sensu::Repo]',
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

        it {
          should contain_service('sensu-backend').with({
            'ensure' => 'running',
            'enable' => true,
            'name'   => 'sensu-backend',
          })
        }
      end

      context 'with use_ssl => true' do
        let(:params) { { :use_ssl => true } }

        it {
          should contain_sensu_api_validator('sensu').with({
            'sensu_api_server' => '127.0.0.1',
            'sensu_api_port'   => 8080,
            'use_ssl'          => 'true',
            'require'          => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_sensu_configure('puppet').with({
            'url'                 => 'https://127.0.0.1:8080',
            'username'            => 'admin',
            'password'            => 'P@ssw0rd!',
            'bootstrap_password'  => 'P@ssw0rd!',
          })
        }
      end
    end
  end
end

