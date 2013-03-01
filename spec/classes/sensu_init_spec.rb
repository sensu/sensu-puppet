require 'spec_helper'

describe 'sensu', :type => :class do

  context 'defaults' do
    let(:params) { { :rabbitmq_password => 'asdfjkl' } }
    let(:facts) { { :fqdn => 'myhost.domain.com', :ipaddress => '1.2.3.4' } }

    it { should contain_class('sensu::package').with(
      'version'         => 'latest',
      'install_repo'    => true,
      'notify_services' => 'Class[Sensu::Service::Client]'
    )}

    it { should contain_class('sensu::rabbitmq').with(
      'ssl_cert_chain'  => '',
      'ssl_private_key' => '',
      'port'            => '5671',
      'host'            => 'localhost',
      'user'            => 'sensu',
      'password'        => 'asdfjkl',
      'vhost'           => '/sensu',
      'notify_services' => 'Class[Sensu::Service::Client]'
    )}

    it { should contain_class('sensu::server').with(
      'redis_host'          => 'localhost',
      'redis_port'          => '6379',
      'api_host'            => 'localhost',
      'api_port'            => '4567',
      'dashboard_host'      => '1.2.3.4',
      'dashboard_port'      => '8080',
      'dashboard_user'      => 'admin',
      'dashboard_password'  => 'secret',
      'enabled'             => 'false'
    )}

    it { should contain_class('sensu::client').with(
      'address'       => '1.2.3.4',
      'subscriptions' => [],
      'client_name'   => 'myhost.domain.com',
      'enabled'       => 'true'
    )}

    it { should contain_class('sensu::service::server').with_enabled('false') }
    it { should contain_class('sensu::service::client').with_enabled('true') }
  end


  context 'setting all params' do
    let(:params) { {
      :rabbitmq_password        => 'asdfjkl',
      :server                   => true,
      :client                   => false,
      :version                  => '0.9.10',
      :install_repo             => false,
      :rabbitmq_port            => '1234',
      :rabbitmq_host            => 'rabbithost',
      :rabbitmq_user            => 'sensuuser',
      :rabbitmq_vhost           => '/vhost',
      :rabbitmq_ssl_private_key => '/etc/sensu/ssl/key.pem',
      :rabbitmq_ssl_cert_chain  => '/etc/sensu/ssl/cert.pem',
      :redis_host               => 'redishost',
      :redis_port               => '2345',
      :api_host                 => 'apihost',
      :api_port                 => '3456',
      :dashboard_host           => 'dashhost',
      :dashboard_port           => '5678',
      :dashboard_user           => 'dashuser',
      :dashboard_password       => 'dashpass',
      :subscriptions            => ['all'],
      :client_address           => '127.0.0.1',
      :client_name              => 'myhost',
      :plugins                  => [ 'puppet:///data/plug1', 'puppet:///data/plug2' ]
    } }

    it { should contain_class('sensu::package').with(
      'version'         => '0.9.10',
      'install_repo'    => false,
      'notify_services' => 'Class[Sensu::Service::Server]'
    )}

    it { should contain_class('sensu::rabbitmq').with(
      'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
      'ssl_private_key' => '/etc/sensu/ssl/key.pem',
      'port'            => '1234',
      'host'            => 'rabbithost',
      'user'            => 'sensuuser',
      'password'        => 'asdfjkl',
      'vhost'           => '/vhost',
      'notify_services' => 'Class[Sensu::Service::Server]'
    )}

    it { should contain_class('sensu::server').with(
      'redis_host'          => 'redishost',
      'redis_port'          => '2345',
      'api_host'            => 'apihost',
      'api_port'            => '3456',
      'dashboard_host'      => 'dashhost',
      'dashboard_port'      => '5678',
      'dashboard_user'      => 'dashuser',
      'dashboard_password'  => 'dashpass',
      'enabled'             => 'true'
    )}

    it { should contain_class('sensu::client').with(
      'address'       => '127.0.0.1',
      'subscriptions' => ['all'],
      'client_name'   => 'myhost',
      'enabled'       => 'false'
    )}

    it { should contain_class('sensu::service::server').with_enabled('true') }
    it { should contain_class('sensu::service::client').with_enabled('false') }
    
    it { should contain_sensu__plugin('puppet:///data/plug1') }
    it { should contain_sensu__plugin('puppet:///data/plug2') }
  end

  context 'server and client' do
    let(:params) { { :rabbitmq_password => 'asdfjkl', :server => 'true', :client => 'true' } }
    let(:facts) { { :fqdn => 'myhost.domain.com', :ipaddress => '1.2.3.4' } }

    it { should contain_class('sensu::rabbitmq').with(
      'notify_services' => ['Class[Sensu::Service::Client]', 'Class[Sensu::Service::Server]']
    )}
  end

  context 'neither server nor client' do
    let(:params) { { :rabbitmq_password => 'asdfjkl', :server => 'false', :client => 'false' } }
    let(:facts) { { :fqdn => 'myhost.domain.com', :ipaddress => '1.2.3.4' } }

    it { should contain_class('sensu::rabbitmq').with(
      'notify_services'  => []
    )}
  end

end



