require 'spec_helper'

describe 'sensu::subscription', :type => :define do
  context 'without whitespace in name' do
    let(:title) { 'mysubscription' }

    context 'defaults' do
      it { should contain_sensu_client_subscription('mysubscription') }
    end

    context 'setting params' do
      let(:params) { {
        :custom => { 'a' => 'b', 'array' => [ 'c', 'd' ] },
      } }

      it { should contain_sensu_client_subscription('mysubscription').with(
        :custom => { 'a' => 'b', 'array' => [ 'c', 'd' ] }
      ) }
    end

    context 'ensure absent' do
      let(:params) { {
        :ensure => 'absent',
      } }

      it { should contain_sensu_client_subscription('mysubscription').with_ensure('absent') }
    end
  end

  context 'notifications' do
    let(:title) { 'mysubscription' }

    it { should contain_sensu_client_subscription('mysubscription').with(:notify => 'Class[Sensu::Client::Service]' ) }
  end
end
