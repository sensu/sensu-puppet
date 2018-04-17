require 'spec_helper'

describe 'sensu::backend', :type => :class do
  describe 'with default values for all parameters' do
    it { should compile.with_all_deps }

    it { should contain_class('sensu::backend')}

    it {
      should contain_package('sensu-cli').with({
        'ensure' => 'installed',
        'name'   => 'sensu-cli',
      })
    }

    it {
      should contain_exec('sensuctl_configure').with({
        'command' => "sensuctl configure -n --url 'http://127.0.0.1:8080' --username 'admin' --password 'P@ssw0rd!'",
        'creates' => '/root/.config/sensu/sensuctl/cluster',
        'path'    => '/bin:/sbin:/usr/bin:/usr/sbin',
        'require' => 'Package[sensu-cli]',
      })
    }

    it {
      should contain_package('sensu-backend').with({
        'ensure' => 'installed',
        'name'   => 'sensu-backend',
      })
    }

    backend_content = <<-END.gsub(/^\s+\|/, '')
      |--- {}
    END

    it {
      should contain_file('sensu_backend_config').with({
        'ensure'  => 'file',
        'path'    => '/etc/sensu/backend.yml',
        'content' => backend_content,
        'require' => 'Package[sensu-backend]',
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
