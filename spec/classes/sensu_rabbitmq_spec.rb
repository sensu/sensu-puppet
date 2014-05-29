require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) { { :fqdn => 'hostname.domain.com' } }
  let(:params) { { :client => true } }

  context 'rabbitmq config' do
    context 'no ssl (default)' do
      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :ssl_cert_chain  => nil,
        :ssl_private_key => nil
      ) }

    end # no ssl (default)

    context 'when using local key' do
      let(:params) { {
        :rabbitmq_ssl_cert_chain  => '/etc/private/ssl/cert.pem',
        :rabbitmq_ssl_private_key => '/etc/private/ssl/key.pem',
        :rabbitmq_port            => '1234',
        :rabbitmq_host            => 'myhost',
        :rabbitmq_user            => 'sensuuser',
        :rabbitmq_password        => 'sensupass',
        :rabbitmq_vhost           => 'myvhost',
      } }

      it { should_not contain_file('/etc/sensu/ssl/cert.pem') }
      it { should_not contain_file('/etc/sensu/ssl/key.pem') }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :port            => '1234',
        :host            => 'myhost',
        :user            => 'sensuuser',
        :password        => 'sensupass',
        :vhost           => 'myvhost',
        :ssl_cert_chain  => '/etc/private/ssl/cert.pem',
        :ssl_private_key => '/etc/private/ssl/key.pem'
      ) }
    end # when using local key

    context 'when using key in puppet' do
      let(:params) { {
        :rabbitmq_ssl_cert_chain  => 'puppet:///modules/sensu/cert.pem',
        :rabbitmq_ssl_private_key => 'puppet:///modules/sensu/key.pem',
        :rabbitmq_port            => '1234',
        :rabbitmq_host            => 'myhost',
        :rabbitmq_user            => 'sensuuser',
        :rabbitmq_password        => 'sensupass',
        :rabbitmq_vhost           => '/myvhost',
      } }

      it { should contain_file('/etc/sensu/ssl').with_ensure('directory') }
      it { should contain_file('/etc/sensu/ssl/cert.pem').with_source('puppet:///modules/sensu/cert.pem') }
      it { should contain_file('/etc/sensu/ssl/key.pem').with_source('puppet:///modules/sensu/key.pem') }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :port            => '1234',
        :host            => 'myhost',
        :user            => 'sensuuser',
        :password        => 'sensupass',
        :vhost           => '/myvhost',
        :ssl_cert_chain  => '/etc/sensu/ssl/cert.pem',
        :ssl_private_key => '/etc/sensu/ssl/key.pem'
      ) }
    end # when using key in puppet

    context 'purge config' do
      let(:params) { {
        :purge_config => true,
        :server       => false,
        :client       => false
      } }

      it { should contain_file('/etc/sensu/conf.d/rabbitmq.json').with_ensure('absent') }
    end
  end # rabbitmq config

end
