require 'spec_helper'

describe 'sensu::agent::subscription' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'localhost' }
      let(:title) { 'apache' }

      it {
        is_expected.to contain_datacat_fragment('sensu_agent_config-subscription-apache').with({
          'target' => 'sensu_agent_config',
          'data'   => {
            'subscriptions' => ['apache'],
          },
          'order'  => '50',
        })
      }
    end
  end
end
