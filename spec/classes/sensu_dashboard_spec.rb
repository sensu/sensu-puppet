require 'spec_helper'

describe 'sensu', :type => :class do

  context 'without dashboard (default)' do

    context 'managing services' do
      it { should contain_service('sensu-dashboard').with(
        :ensure     => 'stopped',
        :enable     => false,
        :hasrestart => true
      )}
    end # managing services

    context 'not managing services' do
      let(:params) { { :manage_services => false } }
      it { should_not contain_service('sensu-dashboard') }
    end # not managing services

    context 'purge config' do
      let(:params) { {
        :purge_config => true,
        :server       => false,
        :api          => false,
        :dashboard    => false,
      } }

      it { should contain_file('/etc/sensu/conf.d/dashboard.json').with_ensure('absent') }

    end # purge config

  end # without dashboard

  context 'with dashboard' do
    let(:facts) { { :fqdn => 'test.domain.com', :ipaddress => '1.2.3.4' } }

    context 'config' do

      context 'defaults' do
        let(:params) { { :dashboard => true } }
        it { should contain_sensu_dashboard_config('test.domain.com').with(
          :ensure   => 'present',
          :host     => '1.2.3.4',
          :port     => 8080,
          :user     => 'admin',
          :password => 'secret'
        ) }
      end # defaults

      context 'set config params' do
        let(:params) { {
          :dashboard          => true,
          :dashboard_host     => 'sensu.domain.com',
          :dashboard_port     => 2345,
          :dashboard_user     => 'user',
          :dashboard_password => 'pass',
        } }
        it { should contain_sensu_dashboard_config('test.domain.com').with(
          :ensure   => 'present',
          :host     => 'sensu.domain.com',
          :port     => 2345,
          :user     => 'user',
          :password => 'pass'
        ) }
      end # set config params

      context 'purge config' do
        let(:params) { {
          :dashboard    => true
        } }

        it { should contain_file('/etc/sensu/conf.d/dashboard.json').with_ensure('present') }

      end # purge config

    end # config

    context 'service' do

      context 'managing services' do
        let(:params) { { :dashboard => true } }
        it { should contain_service('sensu-dashboard').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => true
        )}
      end # managing services

      context 'not managing services' do
        let(:params) { { :dashboard => true, :manage_services => false } }
        it { should_not contain_service('sensu-dashboard') }
      end # not managing services

    end # service

  end # with dashboard

end
