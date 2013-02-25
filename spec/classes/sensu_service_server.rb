require 'spec_helper'

describe 'sensu::service::server', :type => :class do

  context 'enabled' do
    let(:params) { { :enabled => 'true' } }

    it { should contain_service('sensu-server').with(
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasrestart'  => true
    ) }

    it { should contain_service('sensu-api').with(
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasrestart'  => true
    ) }

    it { should contain_service('sensu-dashboard').with(
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasrestart'  => true
    ) }
  end

  context 'disabled' do
    let(:params) { { :enabled => 'false' } }

    it { should contain_service('sensu-server').with(
      'ensure'      => 'stopped',
      'enable'      => 'false',
      'hasrestart'  => true
    ) }

    it { should contain_service('sensu-api').with(
      'ensure'      => 'stopped',
      'enable'      => 'false',
      'hasrestart'  => true
    ) }

    it { should contain_service('sensu-dashboard').with(
      'ensure'      => 'stopped',
      'enable'      => 'false',
      'hasrestart'  => true
    ) }

  end

end
