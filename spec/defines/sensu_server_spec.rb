require 'spec_helper'

describe 'sensu::server', :type => :define do
  let(:title) { 'sensu::server' }

  context 'defaults' do
    let(:params) { { :rabbitmq_password => 'asdfjkl' } }
    let(:facts) { { :fqdn => 'testhost.domain.com', :ipaddress => '1.2.3.4' } }

    it { should include_class('sensu::package') }

    it { should contain_sensu__rabbitmq('server').with(
      'ssl_cert_chain'  => '',
      'ssl_private_key' => '',
      'port'            => '5671',
      'host'            => 'localhost',
      'user'            => 'sensu',
      'password'        => 'asdfjkl',
      'vhost'           => '/sensu'
    ) }

    it { should contain_sensu_redis_config('testhost.domain.com').with(
      'host'  => 'localhost',
      'port'  => '6379'
    ) }

    it { should contain_sensu_api_config('testhost.domain.com').with(
      'host'  => 'localhost',
      'port'  => '4567'
    ) }

    it { should contain_sensu_dashboard_config('testhost.domain.com').with(
      'host'      => '1.2.3.4',
      'port'      => '8080',
      'user'      => 'admin',
      'password'  => 'secret'
    ) }

    it { should contain_service('sensu-server').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[testhost.domain.com]', 'Sensu_redis_config[testhost.domain.com]']
    ) }

    it { should contain_service('sensu-api').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[testhost.domain.com]', 'Sensu_api_config[testhost.domain.com]', 'Service[sensu-server]']
    ) }

    it { should contain_service('sensu-dashboard').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[testhost.domain.com]', 'Sensu_dashboard_config[testhost.domain.com]', 'Service[sensu-api]']
    ) }

    it { should contain_sensu__handler('default').with_type('pipe').with_command('/etc/sensu/handlers/default') }
  end # Defaults

  context 'setting params' do
    let(:facts) { { :fqdn => 'testhost.domain.com', :ipaddress => '1.2.3.4' } }
    let(:params) { {
      :rabbitmq_password        => 'asdfjkl',
      :rabbitmq_port            => '1234',
      :rabbitmq_host            => 'rabbithost',
      :rabbitmq_user            => 'sensuuser',
      :rabbitmq_vhost           => '/myvhost',
      :rabbitmq_ssl_private_key => '/etc/rabbitmq/ssl/key.pem',
      :rabbitmq_ssl_cert_chain  => '/etc/rabbitmq/ssl/chain.pem',
      :redis_host               => 'redishost',
      :redis_port               => '2345',
      :api_host                 => 'apihost',
      :api_port                 => '3456',
      :dashboard_host           => 'dashhost',
      :dashboard_port           => '5678',
      :dashboard_user           => 'user',
      :dashboard_password       => 'mypass'
    } }

    it { should include_class('sensu::package') }

    it { should contain_sensu__rabbitmq('server').with(
      'ssl_cert_chain'  => '/etc/rabbitmq/ssl/chain.pem',
      'ssl_private_key' => '/etc/rabbitmq/ssl/key.pem',
      'port'            => '1234',
      'host'            => 'rabbithost',
      'user'            => 'sensuuser',
      'password'        => 'asdfjkl',
      'vhost'           => '/myvhost'
    ) }

    it { should contain_sensu_redis_config('testhost.domain.com').with(
      'host'  => 'redishost',
      'port'  => '2345'
    ) }

    it { should contain_sensu_api_config('testhost.domain.com').with(
      'host'  => 'apihost',
      'port'  => '3456'
    ) }

    it { should contain_sensu_dashboard_config('testhost.domain.com').with(
      'host'      => 'dashhost',
      'port'      => '5678',
      'user'      => 'user',
      'password'  => 'mypass'
    ) }

    it { should contain_service('sensu-server').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[testhost.domain.com]', 'Sensu_redis_config[testhost.domain.com]']
    ) }

    it { should contain_service('sensu-api').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[testhost.domain.com]', 'Sensu_api_config[testhost.domain.com]', 'Service[sensu-server]']
    ) }

    it { should contain_service('sensu-dashboard').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[testhost.domain.com]', 'Sensu_dashboard_config[testhost.domain.com]', 'Service[sensu-api]']
    ) }

    it { should contain_sensu__handler('default').with_type('pipe').with_command('/etc/sensu/handlers/default') }
  end # setting params

end
