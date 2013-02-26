require 'spec_helper'

describe 'sensu::package', :type => :class do
  let(:facts) { { :fqdn => 'testhost.domain.com' } }

  context 'defaults' do
    it { should create_class('sensu::package') }
    it { should include_class('sensu::repo') }
    it { should contain_package('sensu').with_ensure('latest') }
    it { should contain_sensu_clean_config('testhost.domain.com') }
  end

  context 'setting parameters' do
    let(:params) { {
      :version          => '0.9.10',
      :install_repo     => false,
      :notify_services  => 'Class[Sensu::Service::Server]'
    } }

    it { should_not include_class('sensu::repo') }
    it { should contain_package('sensu').with(
      'ensure'  => '0.9.10',
      'notify'  => 'Class[Sensu::Service::Server]'
    ) }
  end

end
