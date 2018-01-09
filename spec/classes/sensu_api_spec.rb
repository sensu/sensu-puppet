require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) do
    {
      :fqdn     => 'testhost.domain.com',
      :osfamily => 'RedHat',
      :kernel   => 'Linux',
    }
  end

  context 'without api (default)' do
    context 'config' do
      context 'with server' do
        let(:params) { { :server => true } }
        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('present') }
      end

      context 'purge config' do
        let(:params) { {
          :purge  => { 'config' => true },
          :server => false,
        } }

        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('absent') }
      end # purge config
    end # config

    context 'managing services' do
      it { should contain_service('sensu-api').with(
        :ensure     => 'stopped',
        :enable     => false,
        :hasrestart => true
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
          :ensure                => 'present',
          :base_path             => '/etc/sensu/conf.d',
          :bind                  => '0.0.0.0',
          :host                  => '127.0.0.1',
          :port                  => 4567,
          :user                  => nil,
          :password              => nil,
          :ssl_port              => nil,
          :ssl_keystore_file     => nil,
          :ssl_keystore_password => nil,
        ) }
      end

      context 'with api_bind specified' do
        let(:params) { {
          :api      => true,
          :api_bind => '10.1.2.3',
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :bind => '10.1.2.3',
        ) }
      end

      context 'with api_host specified' do
        let(:params) { {
          :api      => true,
          :api_host => 'sensuapi.domain.com',
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :host => 'sensuapi.domain.com',
        ) }
      end

      context 'with api_port specified' do
        let(:params) { {
          :api      => true,
          :api_port => 1234,
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :port => 1234,
        ) }
      end

      context 'with api_user specified' do
        let(:params) { {
          :api      => true,
          :api_user => 'myuser',
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :user => 'myuser',
        ) }
      end

      context 'with api_password specified' do
        let(:params) { {
          :api          => true,
          :api_password => 'mypassword',
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :password => 'mypassword',
        ) }
      end

      context 'with api_ssl_port specified' do
        let(:params) { {
          :api          => true,
          :api_ssl_port => 242,
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :ssl_port => 242,
        ) }
      end

      context 'with api_ssl_keystore_file specified' do
        let(:params) { {
          :api                   => true,
          :api_ssl_keystore_file => '/path/to/api.keystore',
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :ssl_keystore_file => '/path/to/api.keystore',
        ) }
      end

      context 'with api_ssl_keystore_password specified' do
        let(:params) { {
          :api                       => true,
          :api_ssl_keystore_password => 'keystore_password',
        } }

        it { should contain_sensu_api_config('testhost.domain.com').with(
          :ssl_keystore_password => 'keystore_password',
        ) }
      end

      context 'purge config' do
        let(:params) { {
          :purge  => { 'config' => true },
          :api    => false,
          :server => false,
        } }

        it { should contain_file('/etc/sensu/conf.d/api.json').with_ensure('absent') }
        it { should contain_sensu_api_config('testhost.domain.com').with_ensure('absent') }
      end # purge config
    end # config

    context 'service' do
      context 'managing services' do
        let(:params) { { :api => true } }
        it { should contain_service('sensu-api').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => true
        )}
        describe '(#433)' do
          it { is_expected.to contain_service('sensu-api').that_subscribes_to('Class[sensu::redis::config]') }
          # GH-433 Make sure the API subscribes to rabbitmq and redis
          it { is_expected.to contain_service('sensu-api').that_subscribes_to('Class[sensu::rabbitmq::config]') }
        end
      end # managing services

      context 'not managing services' do
        let(:params) { { :api => true, :manage_services => false } }
        it { should_not contain_service('sensu-api') }
      end # not managing services

      context 'with hasrestart=false' do
        let(:params) { { :api => true, :hasrestart => false } }
        it { should contain_service('sensu-api').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => false
        )}
      end # with hasrestart=false
    end # service
  end # with api
end
