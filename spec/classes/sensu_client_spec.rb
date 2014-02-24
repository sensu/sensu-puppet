require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) { { :ipaddress => '2.3.4.5', :fqdn => 'host.domain.com' } }

  context 'with client (default)' do

    context 'config' do

      context 'defaults' do
        let(:params) { { :client => true } }
        it { should contain_sensu_client_config('host.domain.com').with(
          :ensure        => 'present',
          :client_name   => 'host.domain.com',
          :address       => '2.3.4.5',
          :subscriptions => [],
          :ensure        => 'present',
          :custom        => {}
        ) }
      end # defaults

      context 'setting config params' do
        let(:params) { {
          :client                   => true,
          :client_address           => '1.2.3.4',
          :subscriptions            => ['all'],
          :client_name              => 'myclient',
          :safe_mode                => true,
          :client_custom            => { 'bool' => true, 'foo' => 'bar' }
        } }

        it { should contain_sensu_client_config('host.domain.com').with( {
          :ensure        => 'present',
          :client_name   => 'myclient',
          :address       => '1.2.3.4',
          :subscriptions => ['all'],
          :ensure        => 'present',
          :safe_mode     => true,
          :custom        => { 'bool' => true, 'foo' => 'bar' }
        } ) }

      end # setting config params

      context 'purge config' do
        let(:params) { { :purge_config => true } }
        it { should contain_file('/etc/sensu/conf.d/client.json').with_ensure('present') }
      end # purge config

    end # config

    context 'service' do

      context 'default' do
        let(:params) { { :client => true } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => true,
        ) }
      end # default

      context 'not managing services' do
        let(:params) { {
          :client           => true,
          :manage_services  => false
        } }
        it { should_not contain_service('sensu-client') }
      end # not managing service

    end #service

  end #with client

  context 'without client' do

    context 'config' do

      context 'purge config' do
        let(:params) { { :purge_config => true, :client => false } }
        it { should contain_file('/etc/sensu/conf.d/client.json').with_ensure('absent') }
      end # purge config

    end # config

    context 'service' do
      context 'managing services' do
        let(:params) { { :client => false } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'stopped',
          :enable     => false,
          :hasrestart => true,
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
