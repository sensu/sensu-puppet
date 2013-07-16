require 'spec_helper'

describe 'sensu::package', :type => :class do
  let(:facts) { { :fqdn => 'testhost.domain.com' } }

  context 'defaults' do
    it { should create_class('sensu::package') }
    it { should include_class('sensu::repo') }
    it { should contain_package('sensu').with_ensure('latest') }
    it { should contain_file('/etc/sensu/handlers').with_ensure('directory').with_require('Package[sensu]') }
    it { should contain_file('/etc/sensu/plugins').with_ensure('directory').with_require('Package[sensu]') }
    it { should contain_file('/etc/sensu/config.json').with_ensure('absent') }
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

  context 'purge_configs' do
    let(:params) { { :purge_config => true } }

    it { should contain_file('/etc/sensu/conf.d/').with(
      'ensure'  => 'directory',
      'purge'   => 'true',
      'recurse' => 'true',
      'force'   => 'true'
    ) }
  end

end
