require 'spec_helper'

describe 'sensu' do
  let(:facts) { { :fqdn => 'testhost.domain.com' } }

  context 'redis config' do

    context 'default settings' do
      it { should contain_sensu_redis_config('testhost.domain.com').with(
        :host => 'localhost',
        :port => 6379
      )}
    end # default settings

    context 'be configurable' do
      let(:params) { {
        :redis_host => 'redis.domain.com',
        :redis_port => 1234
      } }

      it { should contain_sensu_redis_config('testhost.domain.com').with(
        :host => 'redis.domain.com',
        :port => 1234
      )}
    end # be configurable

    context 'with server' do
      let(:params) { { :server => true } }
      it { should contain_file('/etc/sensu/conf.d/redis.json').with_ensure('present') }
    end # with server

    context 'with api' do
      let(:params) { { :api => true } }
      it { should contain_file('/etc/sensu/conf.d/redis.json').with_ensure('present') }
    end # with api

    context 'purge configs' do
      let(:params) { {
        :purge_config => true,
        :server       => false,
        :api          => false,
      } }

      it { should contain_file('/etc/sensu/conf.d/redis.json').with_ensure('absent') }
    end # purge configs

  end #redis config

end
