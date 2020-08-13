require 'spec_helper'

describe 'sensu::web', :type => :class do
  on_supported_os.each do |os, os_facts|
    # Windows is not supported for web
    if os_facts[:os]['family'] == 'windows'
      next
    end
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node) { 'test.example.com' }
      let(:params) { }

      # Class only supported for systemd
      if os_facts['service_provider'] != 'systemd'
        it { is_expected.to compile.and_raise_error(/only supported on systems that support systemd/) }
        next
      end

      context 'with default values for all parameters' do
        it { should compile.with_all_deps }

        it { should create_class('sensu::web') }
        it { should contain_class('sensu') }
        it { should contain_class('sensu::common::user')}
        it { should contain_class('yarn') }

        it do
          is_expected.to contain_file('sensu-web-dir').with({
            ensure: 'directory',
            path: '/opt/sensu-web',
            owner: 'sensu',
            group: 'sensu',
            mode: '0755',
            before: 'Vcsrepo[sensu-web]',
          })
        end

        it do
          is_expected.to contain_vcsrepo('sensu-web').with({
            ensure: 'latest',
            path: '/opt/sensu-web',
            provider: 'git',
            revision: 'v1.0.1',
            source: 'https://github.com/sensu/web.git',
            user: 'sensu',
            notify: 'Exec[sensu-web-touch-install]',
          })
        end

        it do
          is_expected.to contain_exec('sensu-web-touch-install').with({
            path: '/usr/bin:/bin',
            command: 'touch /opt/sensu-web/.install',
            refreshonly: true,
            user: 'sensu',
            before: 'Exec[sensu-web-install]',
          })
        end

        it do
          is_expected.to contain_exec('sensu-web-install').with({
            path: '/usr/bin:/bin:/usr/sbin:/sbin',
            command: 'yarn install && rm -f /opt/sensu-web/.install',
            cwd: '/opt/sensu-web',
            onlyif: 'test -f /opt/sensu-web/.install',
            timeout: '0',
            user: 'sensu',
          })
        end

        systemd_unit_content = <<-END.gsub(/^\s+\|/, '')
        |[Unit]
        |Description=Sensu Go Web
        |After=network-online.target multi-user.target
        |Wants=network-online.target
        |
        |[Service]
        |Environment=NODE_ENV=production
        |Environment=PORT=9080
        |Environment=API_URL=https://test.example.com:8080
        |WorkingDirectory=/opt/sensu-web
        |User=sensu
        |Group=sensu
        |ExecStart=/usr/bin/yarn node scripts serve
        |
        |[Install]
        |WantedBy=multi-user.target
        END
        it do
          is_expected.to contain_systemd__unit_file('sensu-web.service').with(
            content: systemd_unit_content,
            notify: 'Service[sensu-web]',
          )
        end

        if Gem::Version.new(os_facts[:puppetversion]) < Gem::Version.new('6.1.0')
          it { is_expected.to contain_class('systemd::systemctl::daemon_reload').that_comes_before('Service[sensu-web]') }
        end

        it do
          is_expected.to contain_service('sensu-web').with(
            ensure: 'running',
            enable: 'true',
            subscribe: 'Exec[sensu-web-install]',
          )
        end
      end # end defaults

    end
  end
end

