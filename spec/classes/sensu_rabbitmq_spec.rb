require 'spec_helper'

describe 'sensu::rabbitmq', :type => :class do
  let(:title) { 'myrabbit' }
  let(:facts) { { :fqdn => 'hostname.domain.com' } }

  context 'when using local key' do
    let(:params) { {
      :ssl_cert_chain   => '/etc/private/ssl/cert.pem',
      :ssl_private_key  => '/etc/private/ssl/key.pem',
      :port             => '1234',
      :host             => 'myhost',
      :user             => 'sensuuser',
      :password         => 'sensupass',
      :vhost            => '/myvhost',
      :notify_services  => []
    } }

    it { should_not contain_file('/etc/sensu/ssl/cert.pem') }
    it { should_not contain_file('/etc/sensu/ssl/key.pem') }

    it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
      'port'            => '1234',
      'host'            => 'myhost',
      'user'            => 'sensuuser',
      'password'        => 'sensupass',
      'vhost'           => '/myvhost',
      'ssl_cert_chain'  => '/etc/private/ssl/cert.pem',
      'ssl_private_key' => '/etc/private/ssl/key.pem'
    ) }
  end

  context 'when using key in puppet' do
    let(:params) { {
      :ssl_cert_chain   => 'puppet:///modules/sensu/cert.pem',
      :ssl_private_key  => 'puppet:///modules/sensu/key.pem',
      :port             => '1234',
      :host             => 'myhost',
      :user             => 'sensuuser',
      :password         => 'sensupass',
      :vhost            => '/myvhost',
      :notify_services  => ['Class[sensu::service::server]']
    } }

    it { should contain_file('/etc/sensu/ssl').with_ensure('directory') }
    it { should contain_file('/etc/sensu/ssl/cert.pem').with_source('puppet:///modules/sensu/cert.pem') }
    it { should contain_file('/etc/sensu/ssl/key.pem').with_source('puppet:///modules/sensu/key.pem') }

    it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
      'port'            => '1234',
      'host'            => 'myhost',
      'user'            => 'sensuuser',
      'password'        => 'sensupass',
      'vhost'           => '/myvhost',
      'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
      'ssl_private_key' => '/etc/sensu/ssl/key.pem',
      'notify'          => 'Class[sensu::service::server]'
    ) }
  end

end











