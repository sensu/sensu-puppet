require 'spec_helper'

describe 'sensu', :type => :class do
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
        end

        context 'with manage_services => false' do
          let(:params) { {
            :enterprise_user      => 'sensu',
            :enterprise_pass      => 'sensu',
            :enterprise_dashboard => true,
            :manage_services      => false,
          } }
          it { should_not contain_service('puppet-enterprise-dashboard') }
          it { should contain_service('sensu-enterprise-dashboard').with(
            'enable' => false,
            'ensure' => 'stopped'
          ) }
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
            :enterprise_dashboard => false
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
    let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'ubuntu' } }
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
