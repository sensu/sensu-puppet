require 'spec_helper'

describe 'sensu::server', :type => :class do
  let(:title) { 'sensu::server' }

  context 'defaults' do
    let(:facts) { { :fqdn => 'testhost.domain.com' } }
    it { should contain_sensu_redis_config('testhost.domain.com').with_ensure('absent') }
    it { should contain_sensu_api_config('testhost.domain.com').with_ensure('absent') }
    it { should contain_sensu_dashboard_config('testhost.domain.com').with_ensure('absent') }
  end

  context 'defaults (enabled)' do
    let(:facts) { { :fqdn => 'testhost.domain.com', :ipaddress => '1.2.3.4' } }
    let(:params) { { :enabled => 'true' } }

    it { should contain_sensu_redis_config('testhost.domain.com').with(
      'host'    => 'localhost',
      'port'    => '6379',
      'ensure'  => 'present'
    ) }

    it { should contain_sensu_api_config('testhost.domain.com').with(
      'host'    => 'localhost',
      'port'    => '4567',
      'ensure'  => 'present'
    ) }

    it { should contain_sensu_dashboard_config('testhost.domain.com').with(
      'host'      => '1.2.3.4',
      'port'      => '8080',
      'user'      => 'admin',
      'password'  => 'secret',
      'ensure'    => 'present'
    ) }

  end # Defaults

  context 'setting params (enabled)' do
    let(:facts) { { :fqdn => 'testhost.domain.com', :ipaddress => '1.2.3.4' } }
    let(:params) { {
      :redis_host               => 'redishost',
      :redis_port               => '2345',
      :api_host                 => 'apihost',
      :api_port                 => '3456',
      :dashboard_host           => 'dashhost',
      :dashboard_port           => '5678',
      :dashboard_user           => 'user',
      :dashboard_password       => 'mypass',
      :enabled                  => 'true'
    } }

    it { should contain_sensu_redis_config('testhost.domain.com').with(
      'host'    => 'redishost',
      'port'    => '2345',
      'ensure'  => 'present'
    ) }

    it { should contain_sensu_api_config('testhost.domain.com').with(
      'host'    => 'apihost',
      'port'    => '3456',
      'ensure'  => 'present'
    ) }

    it { should contain_sensu_dashboard_config('testhost.domain.com').with(
      'host'      => 'dashhost',
      'port'      => '5678',
      'user'      => 'user',
      'password'  => 'mypass',
      'ensure'    => 'present'
    ) }
  end # setting params

end
