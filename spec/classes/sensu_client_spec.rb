require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) { { :ipaddress => '2.3.4.5', :fqdn => 'host.domain.com', :osfamily => 'RedHat' } }
  let(:title) { 'host.domain.com' }

  context 'with client (default)' do
    context 'config' do
      context 'defaults' do
        let(:params) { { :client => true } }
        it { should contain_sensu_client_config('host.domain.com').with(
          :ensure        => 'present',
          :client_name   => 'host.domain.com',
          :address       => '2.3.4.5',
          :socket        => { 'bind' => '127.0.0.1', 'port' => 3030 },
          :subscriptions => [],
          :custom        => {}
        ) }

        it { should contain_sensu_client_config('host.domain.com').without_redact }
        it { should contain_sensu_client_config('host.domain.com').without_deregister }
        it { should contain_sensu_client_config('host.domain.com').without_deregistration }
      end # defaults

      context 'setting config params' do
        let(:params_base) do
          {
            :client         => true,
            :client_address => '1.2.3.4',
            :subscriptions  => ['all'],
            :redact         => ['password'],
            :client_name    => 'myclient',
            :safe_mode      => true,
            :client_custom  => { 'bool' => true, 'foo' => 'bar' },
          }
        end
        let(:params_override) { {} }
        let(:params) { params_base.merge(params_override) }

        describe 'multiple attributes at once' do
          let(:params) { {
            :client                   => true,
            :client_address           => '1.2.3.4',
            :subscriptions            => ['all'],
            :redact                   => ['password'],
            :client_name              => 'myclient',
            :safe_mode                => true,
            :client_custom            => { 'bool' => true, 'foo' => 'bar' }
          } }

          it { should contain_sensu_client_config('host.domain.com').with( {
            :ensure        => 'present',
            :client_name   => 'myclient',
            :address       => '1.2.3.4',
            :socket        => { 'bind' => '127.0.0.1', 'port' => 3030 },
            :subscriptions => ['all'],
            :redact        => ['password'],
            :safe_mode     => true,
            :custom        => { 'bool' => true, 'foo' => 'bar' }
          } ) }
        end

        describe 'deregister' do
          context '=> false' do
            let(:params_override) { {client_deregister: false} }
            it { is_expected.to contain_sensu_client_config(title).with(deregister: false) }
          end

          context '=> true' do
            let(:params_override) { {client_deregister: true} }
            it { is_expected.to contain_sensu_client_config(title).with(deregister: true) }
          end

          context '=> "garbage"' do
            let(:params_override) { {client_deregister: 'garbage'} }
            it { is_expected.to raise_error(Puppet::Error) }
          end
        end

        describe 'client_deregistration' do
          let(:params_override) { {client_deregistration: deregistration} }
          context "=> {'handler': 'deregister_client'}" do
            let(:deregistration) { {'handler' => 'deregister_client'} }
            it { is_expected.to contain_sensu_client_config(title).with(deregistration: deregistration) }
          end

          context "=> {}" do
            let(:deregistration) { {} }
            it { is_expected.to contain_sensu_client_config(title).with(deregistration: deregistration) }
          end

          context "=> 'absent' (error)" do
            let(:deregistration) { 'absent' }
            it { is_expected.to raise_error(Puppet::Error) }
          end
        end
      end

      context 'purge config' do
        let(:params) { { :purge => { 'config' => true } } }
        it { should contain_file('/etc/sensu/conf.d/client.json').with_ensure('present') }
      end # purge config
    end # config

    context 'service' do
      context 'default' do
        let(:params) { { :client => true } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => true
        ) }
      end # default

      context 'not managing services' do
        let(:params) { {
          :client           => true,
          :manage_services  => false
        } }
        it { should_not contain_service('sensu-client') }
      end # not managing service

      context 'with hasrestart=false' do
        let(:params) { { :client => true, :hasrestart => false } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => false
        ) }
      end # with hasrestart=false
    end #service
  end #with client

  context 'without client' do
    context 'config' do
      context 'purge config' do
        let(:params) { { :purge => { 'config' => true }, :client => false } }
        it { should contain_file('/etc/sensu/conf.d/client.json').with_ensure('absent') }
      end # purge config
    end # config

    context 'service' do
      context 'managing services' do
        let(:params) { { :client => false } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'stopped',
          :enable     => false,
          :hasrestart => true
        ) }
      end # managing services

      context 'no client, not managing services' do
        let(:params) { {
          :client           => false,
          :manage_services  => false
        } }
        it { should_not contain_service('sensu-client') }
      end #no client, not managing services
    end # service
  end # without client
end
