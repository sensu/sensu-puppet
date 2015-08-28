require 'spec_helper'

describe 'sensu' do
  let(:facts) { { :fqdn => 'testhost.domain.com', :osfamily => 'RedHat' } }

  context 'redis config' do

    context 'default settings' do
      it { should contain_sensu_redis_config('testhost.domain.com').with(
        :host           => 'localhost',
        :port           => 6379,
        :db             => 0,
        :auto_reconnect => true
      )}
    end # default settings

    context 'be configurable' do
      let(:params) { {
        :redis_host           => 'redis.domain.com',
        :redis_port           => 1234,
        :redis_password       => 'password',
        :redis_db             => 1,
        :redis_auto_reconnect => false
      } }

      it { should contain_sensu_redis_config('testhost.domain.com').with(
        :host           => 'redis.domain.com',
        :port           => 1234,
        :password       => 'password',
        :db             => 1,
        :auto_reconnect => false        
      )}
    end # be configurable

    context 'with server' do
      let(:params) { { :server => true } }
      it do
        should contain_file('/etc/sensu/conf.d/redis.json').with(
          :ensure => 'present',
          :owner  => 'sensu',
          :group  => 'sensu',
          :mode   => '0440'
        ).that_comes_before("Sensu_redis_config[#{facts[:fqdn]}]")
      end
    end # with server

    context 'with api' do
      let(:params) { { :api => true } }
      it do
        should contain_file('/etc/sensu/conf.d/redis.json').with(
          :ensure => 'present',
          :owner  => 'sensu',
          :group  => 'sensu',
          :mode   => '0440'
        ).that_comes_before("Sensu_redis_config[#{facts[:fqdn]}]")
      end
    end # with api

    context 'purge configs' do
      let(:params) { {
        :purge  => { 'config' => true },
        :server => false,
        :api    => false,
      } }

      it { should contain_file('/etc/sensu/conf.d/redis.json').with_ensure('absent') }
    end # purge configs

  end #redis config

end
