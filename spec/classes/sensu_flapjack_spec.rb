require 'spec_helper'

describe 'sensu' do
  let(:facts) { { :fqdn => 'testhost.domain.com', :osfamily => 'RedHat' } }

  context 'flapjack config' do

    context 'default settings' do
      it { should contain_sensu_flapjack_config('testhost.domain.com').with(
        :host => 'localhost',
        :port => 6380
      )}
    end # default settings

    context 'be configurable' do
      let(:params) { {
        :flapjack_redis_host => 'flapjack.domain.com',
        :flapjack_redis_port => 1234,
        :flapjack_redis_db   => 2
      } }

      it { should contain_sensu_flapjack_config('testhost.domain.com').with(
        :host => 'flapjack.domain.com',
        :port => 1234,
        :db   => 2
      )}
    end # be configurable

    context 'with server' do
      let(:params) { { :server => true } }
      it { should contain_file('/etc/sensu/conf.d/flapjack.json').with_ensure('present') }
    end # with server

    context 'with api' do
      let(:params) { { :api => true } }
      it { should contain_file('/etc/sensu/conf.d/flapjack.json').with_ensure('present') }
    end # with api

    context 'purge configs' do
      let(:params) { {
        :purge_config => true,
        :server       => false,
        :api          => false,
      } }

      it { should contain_file('/etc/sensu/conf.d/flapjack.json').with_ensure('absent') }
    end # purge configs

  end #flapjack config

end
