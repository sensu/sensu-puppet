require 'spec_helper'

describe 'sensu::service::client', :type => :class do

  context 'enabled' do
    let(:params) { { :enabled => true } }

    it { should contain_service('sensu-client').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true
    ) }

  end

  context 'disabled' do
    let(:params) { { :enabled => false } }

    it { should contain_service('sensu-client').with(
      'ensure'      => 'stopped',
      'enable'      => false,
      'hasrestart'  => true
    ) }

  end

end
