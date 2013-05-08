require 'spec_helper'

describe 'sensu::client', :type => :class do
  let(:title) { 'myclient' }

  context 'defaults' do
    let(:facts) { { :ipaddress => '2.3.4.5', :fqdn => 'host.domain.com' } }

    it { should contain_sensu_client_config('host.domain.com').with(
      'client_name'   => 'host.domain.com',
      'address'       => '2.3.4.5',
      'subscriptions' => [],
      'ensure'        => 'present'
    ) }

  end

  context 'setting params (enabled)' do
    let(:facts) { { :fqdn => 'host.domain.com' } }
    let(:params) { {
      :address                  => '1.2.3.4',
      :subscriptions            => ['all'],
      :client_name              => 'myclient',
      :safe_mode                => true
    } }

    it { should contain_sensu_client_config('host.domain.com').with(
      'client_name'   => 'myclient',
      'address'       => '1.2.3.4',
      'subscriptions' => ['all'],
      'ensure'        => 'present',
      'safe_mode'     => true
    ) }

  end

  context 'disabled' do
    let(:facts) { { :fqdn => 'host.domain.com' } }
    let(:params) { { :enabled => false } }
    it { should contain_sensu_client_config('host.domain.com').with_ensure('absent') }
  end
  
  context 'purge_configs' do
    let(:params) { { :purge_config => true } }

    it { should contain_file('/etc/sensu/conf.d/client.json').with_ensure('present') }
  end

end
