require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) { { :fqdn => 'testhost.domain.com' } }

  context 'without api (default)' do

    context 'config' do

      context 'with server' do
        let(:params) { { :server => true } }
        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('present') }
      end

      context 'wtih dashboard' do
        let(:params) { { :dashboard => true } }
        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('present') }
      end

      context 'purge config' do
        let(:params) { {
          :purge_config => true,
          :server       => false,
          :dashboard    => false
        } }

        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('absent') }

      end # purge config

    end # config

    context 'managing services' do
      it { should contain_service('sensu-api').with(
        :ensure     => 'stopped',
        :enable     => false,
        :hasrestart => true,
      )}
    end # managing services

    context 'not managing services' do
      let(:params) { { :manage_services => false } }
      it { should_not contain_service('sensu-api') }
    end # not managing services

  end # without api

  context 'with api' do

    context 'config' do

      context 'defaults' do
        let(:params) { { :api => true } }
        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('present') }
        it { should contain_sensu_api_config('testhost.domain.com').with(
          :ensure => 'present',
          :host   => 'localhost',
          :port   => 4567
        ) }
        it { should contain_sensu_api_config('testhost.domain.com').without_api_user }
        it { should contain_sensu_api_config('testhost.domain.com').without_api_password }
      end # defaults

      context 'set config params' do
        let(:params) { {
          :api      => true,
          :api_host => 'sensuapi.domain.com',
          :api_port => 5678
        } }
        it { should contain_sensu_api_config('testhost.domain.com').with(
          :ensure => 'present',
          :host   => 'sensuapi.domain.com',
          :port   => 5678
        ) }
        it { should contain_sensu_api_config('testhost.domain.com').without_api_user }
        it { should contain_sensu_api_config('testhost.domain.com').without_api_password }
      end # set config params

      context 'set config params including authentication' do
        let(:params) { {
          :api          => true,
          :api_host     => 'sensuapi.domain.com',
          :api_port     => 5678,
          :api_user     => 'test_user',
          :api_password => 'test_password'
        } }
        it { should contain_sensu_api_config('testhost.domain.com').with(
          :ensure   => 'present',
          :host     => 'sensuapi.domain.com',
          :port     => 5678,
          :user     => 'test_user',
          :password => 'test_password'
        ) }
      end # set config params

      context 'purge config' do
        let(:params) { {
          :purge_config => true,
          :api          => false,
          :server       => false,
          :dashboard    => false,
        } }

        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('absent') }

      end # purge config

    end # config

    context 'service' do

      context 'managing services' do
        let(:params) { { :api => true } }
        it { should contain_service('sensu-api').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => true,
        )}
      end # managing services

      context 'not managing services' do
        let(:params) { { :api => true, :manage_services => false } }
        it { should_not contain_service('sensu-api') }
      end # not managing services

    end # service

  end # with api

end
