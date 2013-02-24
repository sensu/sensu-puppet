require 'spec_helper'

describe 'sensu::client', :type => :define do
  let(:title) { 'myclient' }

  context 'defaults' do
    let(:facts) { { :ipaddress => '2.3.4.5', :fqdn => 'host.domain.com' } }
    let(:params) { { :rabbitmq_password => 'asdfjkl' } }

    it { should include_class('sensu::package') }
    it { should contain_sensu__rabbitmq('client').with(
      'ssl_cert_chain'  => '',
      'ssl_private_key' => '',
      'port'            => '5671',
      'host'            => 'localhost',
      'user'            => 'sensu',
      'vhost'           => '/sensu',
      'password'        => 'asdfjkl'
    ) }

    it { should contain_sensu_client_config('host.domain.com').with(
      'client_name'   => 'myclient',
      'address'       => '2.3.4.5',
      'subscriptions' => []
    ) }

    it { should contain_service('sensu-client').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[host.domain.com]', 'Sensu_client_config[host.domain.com]']
    ) }
  end

  context 'setting params' do
    let(:facts) { { :fqdn => 'host.domain.com' } }
    let(:params) { {
      :rabbitmq_password        => 'asdfjkl',
      :rabbitmq_ssl_private_key => '/etc/sensu/ssl/key.pem',
      :rabbitmq_ssl_cert_chain  => '/etc/sensu/ssl/chain.pem',
      :rabbitmq_port            => '1234',
      :rabbitmq_host            => 'rabbithost',
      :rabbitmq_user            => 'sensuuser',
      :rabbitmq_vhost           => '/myvhost',
      :address                  => '1.2.3.4',
      :subscriptions            => ['all']
    } }

    it { should include_class('sensu::package') }
    it { should contain_sensu__rabbitmq('client').with(
      'ssl_cert_chain'  => '/etc/sensu/ssl/chain.pem',
      'ssl_private_key' => '/etc/sensu/ssl/key.pem',
      'port'            => '1234',
      'host'            => 'rabbithost',
      'user'            => 'sensuuser',
      'vhost'           => '/myvhost',
      'password'        => 'asdfjkl'
    ) }

    it { should contain_sensu_client_config('host.domain.com').with(
      'client_name'   => 'myclient',
      'address'       => '1.2.3.4',
      'subscriptions' => ['all']
    ) }

    it { should contain_service('sensu-client').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true,
      'require'     => ['Sensu_rabbitmq_config[host.domain.com]', 'Sensu_client_config[host.domain.com]']
    ) }
  end

end
