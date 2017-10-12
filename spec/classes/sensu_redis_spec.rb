require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) do
    {
      :fqdn     => 'testhost.domain.com',
      :osfamily => 'RedHat',
      :kernel   => 'Linux',
    }
  end
  let(:pre_condition) { 'Package{ provider => "yum"}' }

  context 'redis config' do
    context 'default settings' do

      it { should contain_file('/etc/sensu/conf.d/redis.json').with(
        :ensure => 'present',
        :owner  => 'sensu',
        :group  => 'sensu',
        :mode   => '0440',
        :before => 'Sensu_redis_config[testhost.domain.com]',
      )}

      it { should contain_sensu_redis_config('testhost.domain.com').with(
        :ensure             => 'present',
        :base_path          => '/etc/sensu/conf.d',
        :host               => '127.0.0.1',
        :port               => 6379,
        :reconnect_on_error => true,
        :db                 => 0,
        :auto_reconnect     => true,
        :sentinels          => nil,
        :master             => nil,
      )}
    end # default settings

    [true,false].each do |value|
      context "with reconnect_on_error specified as #{value}" do
        let(:params) { { :redis_reconnect_on_error => value } }

        it { should contain_sensu_redis_config('testhost.domain.com').with(
          :reconnect_on_error => value,
        )}
      end
    end

    context 'be configurable without sentinels' do
      let(:params) { {
        :redis_host           => 'redis.domain.com',
        :redis_port           => 1234,
        :redis_password       => 'password',
        :redis_db             => 1,
        :redis_auto_reconnect => false,
      } }

      it { should contain_sensu_redis_config('testhost.domain.com').with(
        :host           => 'redis.domain.com',
        :port           => 1234,
        :password       => 'password',
        :db             => 1,
        :auto_reconnect => false,
        :sentinels      => nil,
        :master         => nil,
      )}
    end # be configurable without sentinels

    context 'be configurable with sentinels' do
      let(:params) { {
        :redis_password       => 'password',
        :redis_db             => 1,
        :redis_auto_reconnect => false,
        :redis_sentinels      => [{
            'host' => 'redis1.domain.com',
            'port' => 1234,
        }, {
            'host' => 'redis2.domain.com',
            'port' => '5678',
        }],
        :redis_master         => 'master-name',
      } }

      it { should contain_sensu_redis_config('testhost.domain.com').with(
        :host           => nil,
        :port           => nil,
        :password       => 'password',
        :db             => 1,
        :auto_reconnect => false,
        :sentinels      => [{
            'host' => 'redis1.domain.com',
            'port' => 1234,
        }, {
            'host'  => 'redis2.domain.com',
            'port'  => 5678,
        }],
        :master         => "master-name",
      )}
    end # be configurable with sentinels

    context 'with server' do
      let(:params) { { :server => true } }
      it do
        should contain_file('/etc/sensu/conf.d/redis.json').with(
          :ensure => 'present',
          :owner  => 'sensu',
          :group  => 'sensu',
          :mode   => '0440',
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
          :mode   => '0440',
        ).that_comes_before("Sensu_redis_config[#{facts[:fqdn]}]")
      end
    end # with api

    context 'purge configs' do
      let(:params) { {
        :purge          => { 'config' => true },
        :server         => false,
        :api            => false,
        :client         => false,
        :enterprise     => false,
        :transport_type => 'rabbitmq',
      } }

      it { should contain_file('/etc/sensu/conf.d/redis.json').with_ensure('absent') }
    end # purge configs
  end #redis config
end
