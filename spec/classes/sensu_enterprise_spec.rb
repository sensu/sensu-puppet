require 'spec_helper'

describe 'sensu', :type => :class do
  let(:params_base) { {
    :enterprise      => true,
    :enterprise_user => 'sensu',
    :enterprise_pass => 'sensu',
  } }

  context 'on RedHat' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :fqdn     => 'testhost.domain.com'
    } }

    context 'with enterprise => true' do
      context 'with valid enterprise_pass' do
        context 'with enterprise_dashboard => false' do
          let(:params) { {
            :enterprise      => true,
            :enterprise_user => 'sensu',
            :enterprise_pass => 'sensu',
          } }
          it { should contain_yumrepo('sensu-enterprise').with(
            :baseurl => 'http://sensu:sensu@enterprise.sensuapp.com/yum/noarch/'
          ) }
          it { should contain_service('sensu-enterprise') }
          it { should_not contain_yumrepo('sensu-enterprise-dashboard') }
          it { should contain_package('sensu-enterprise') }

          it do
            should contain_file('/etc/default/sensu-enterprise').with({
              'ensure'  => 'file',
              'owner'   => '0',
              'group'   => '0',
              'mode'    => '0444',
              'require' => 'Package[sensu-enterprise]',
            })
          end
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^EMBEDDED_RUBY=true$}) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^LOG_LEVEL=info$}) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^LOG_DIR=/var/log/sensu$}) }
          it { should contain_file('/etc/default/sensu-enterprise').without_content(%r{^RUBYOPT=.*$}) }
          it { should contain_file('/etc/default/sensu-enterprise').without_content(%r{^GEM_PATH=.*$}) }
          it { should contain_file('/etc/default/sensu-enterprise').without_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=.*$}) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^SERVICE_MAX_WAIT="10"$}) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^PATH=\$PATH$}) }
          it { should contain_file('/etc/default/sensu-enterprise').without_content(%r{^HEAP_SIZE=.*$}) }
        end

        context 'with use_embedded_ruby => false' do
          let(:params) { params_base.merge({ :use_embedded_ruby => false }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^EMBEDDED_RUBY=false$}) }
        end

        context 'with log_level => debug' do
          let(:params) { params_base.merge({ :log_level => 'debug' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^LOG_LEVEL=debug$}) }
        end

        context 'with log_dir => /var/log/tests' do
          let(:params) { params_base.merge({ :log_dir => '/var/log/tests' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^LOG_DIR=/var/log/tests$}) }
        end

        context 'with rubyopt => -rbundler/test' do
          let(:params) { params_base.merge({ :rubyopt => '-rbundler/test' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^RUBYOPT="-rbundler/test"$}) }
        end

        context 'with gem_path => /path/to/gems' do
          let(:params) { params_base.merge({ :gem_path => '/path/to/gems' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^GEM_PATH="/path/to/gems"$}) }
        end

        context 'with deregister_on_stop => true' do
          let(:params) { params_base.merge({ :deregister_on_stop => true }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=""$}) }
        end

        # without deregister_on_stop == true deregister_handler will be ignored
        context 'with deregister_handler => testing' do
          let(:params) { params_base.merge({ :deregister_handler => 'testing' }) }
          it { should contain_file('/etc/default/sensu-enterprise').without_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=.*$}) }
        end

        context 'deregister_on_stop => true & deregister_handler => testing' do
          let(:params) { params_base.merge({ :deregister_on_stop => true, :deregister_handler => 'testing' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER="testing"$}) }
        end

        context 'with init_stop_max_wait => 242' do
          let(:params) { params_base.merge({ :init_stop_max_wait => 242 }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^SERVICE_MAX_WAIT="242"$}) }
        end

        context 'with path => /spec/tests' do
          let(:params) { params_base.merge({ :path => '/spec/tests' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^PATH=/spec/tests$}) }
        end

        context 'heap_size => 256' do
          let(:params) { params_base.merge({:heap_size => 256 }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^HEAP_SIZE="256"$}) }
        end

        context 'heap_size => "256M"' do
          let(:params) { params_base.merge({:heap_size => '256M'}) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^HEAP_SIZE="256M"$}) }
        end

        context 'max_open_files => 20000' do
          let(:params) { params_base.merge({:max_open_files => 20000 }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^MAX_OPEN_FILES="20000"$}) }
        end

        context 'heap_dump_path => /tmp/test' do
          let(:params) { params_base.merge({:heap_dump_path => '/tmp/test' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^HEAP_DUMP_PATH="/tmp/test"$}) }
        end

        context 'java_opts => -Xms256m -Xmx512m' do
          let(:params) { params_base.merge({:java_opts => '-Xms256m -Xmx512m' }) }
          it { should contain_file('/etc/default/sensu-enterprise').with_content(%r{^JAVA_OPTS="-Xms256m -Xmx512m"$}) }
        end

        context 'with manage_services => false' do
          let(:params) { {
            :enterprise_user      => 'sensu',
            :enterprise_pass      => 'sensu',
            :enterprise_dashboard => true,
            :manage_services      => false,
          } }
          it { should_not contain_service('sensu-enterprise-dashboard') }
        end

        context 'with enterprise_dashboard => true' do
          context 'with enterprise_dashboard_version => latest' do
            let(:params) { {
              :enterprise           => true,
              :enterprise_user      => 'sensu',
              :enterprise_pass      => 'sensu',
              :enterprise_dashboard => true
            } }
            it { should contain_yumrepo('sensu-enterprise') }
            it { should contain_service('sensu-enterprise') }
            it { should contain_package('sensu-enterprise') }

            it { should contain_yumrepo('sensu-enterprise-dashboard') }
            it { should contain_service('sensu-enterprise-dashboard') }
            it { should contain_package('sensu-enterprise-dashboard') }
            it { should contain_file('/etc/sensu/dashboard.json') }
            it { should contain_sensu_enterprise_dashboard_config('testhost.domain.com') }
          end

          context 'with enterprise_dashboard_version => 1.3.1-1' do
            let(:params) { {
              :enterprise                   => true,
              :enterprise_user              => 'sensu',
              :enterprise_pass              => 'sensu',
              :enterprise_dashboard         => true,
              :enterprise_dashboard_version => '1.3.1-1'
            } }
            it { should contain_yumrepo('sensu-enterprise') }
            it { should contain_service('sensu-enterprise') }
            it { should contain_package('sensu-enterprise') }

            it { should contain_yumrepo('sensu-enterprise-dashboard') }
            it { should contain_service('sensu-enterprise-dashboard') }
            it { should contain_package('sensu-enterprise-dashboard').with({
              'ensure' => '1.3.1-1'
            }) }
            it { should contain_file('/etc/sensu/dashboard.json') }
            it { should contain_sensu_enterprise_dashboard_config('testhost.domain.com') }
          end
        end

        context 'with rabbitmq_ssl => true and rabbitmq_ssl_cert_chain => undef' do
          let(:params) { {
            :enterprise               => true,
            :enterprise_user          => 'sensu',
            :enterprise_pass          => 'sensu',
            :enterprise_dashboard     => true,
            :rabbitmq_ssl             => true,
            :rabbitmq_ssl_private_key => '/etc/certificates/private.key'
          } }

          it { should contain_sensu_rabbitmq_config('testhost.domain.com').with(
            'ssl_transport'   => true,
            'ssl_private_key' => '/etc/certificates/private.key'
          ) }
        end

        context 'with enterprise_dashboard => false' do
          let(:params) { {
            :enterprise           => true,
            :enterprise_user      => 'sensu',
            :enterprise_pass      => 'sensu',
            :enterprise_dashboard => false,
            :manage_services      => true,
          } }
          it { should contain_yumrepo('sensu-enterprise') }
          it { should contain_service('sensu-enterprise') }
          it { should_not contain_yumrepo('sensu-enterprise-dashboard') }
          it { should_not contain_service('sensu-enterprise-dashboard') }
        end
      end

      context 'invalid user or pass' do
        let(:params) { {
          :enterprise      => true,
          :enterprise_user => 'sensu',
        } }
        it { expect {
          should raise_error(Puppet::Error, /Sensu Enterprise repo/)
        } }
      end
    end
  end

  context 'on Debian' do
    let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'ubuntu', :lsbdistrelease => '14.04', :lsbdistcodename => 'trusty', :os => {:name => 'ubuntu', :release => {:full => '14.04'} }, } }
    context 'when enterprise => true' do
      let(:params) { {
        :enterprise => true,
        :enterprise_user => 'sensu',
        :enterprise_pass => 'sensu',
      } }
      it { should contain_apt__source('sensu-enterprise').with(
        :release => 'sensu-enterprise'
      ) }
    end
  end
end
