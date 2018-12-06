require 'spec_helper'

describe 'sensu::backend', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      describe 'with default values for all parameters' do
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
            'require'          => 'Service[sensu-backend]',
          })
        }

        it {
          should contain_exec('sensuctl_configure').with({
            'command' => "sensuctl configure -n --url 'http://127.0.0.1:8080' --username 'admin' --password 'P@ssw0rd!' || rm -f /root/.config/sensu/sensuctl/cluster",
            'creates' => '/root/.config/sensu/sensuctl/cluster',
            'path'    => '/bin:/sbin:/usr/bin:/usr/sbin',
            'require' => 'Sensu_api_validator[sensu]',
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
    end
  end
end

