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

      it {
        is_expected.to contain_sensu_agent_entity_config('sensu::agent::subscription apache').with({
          'config'    => 'subscriptions',
          'value'     => 'apache',
          'entity'    => 'localhost',
          'namespace' => 'default',
        })
      }

      context 'all params' do
        let(:params) do
          {
            :subscription => 'foo',
            :order        => '01',
          }
        end
        it {
          is_expected.to contain_datacat_fragment('sensu_agent_config-subscription-apache').with({
            'target' => 'sensu_agent_config',
            'data'   => {
              'subscriptions' => ['foo'],
            },
            'order'  => '01',
          })
        }
        it {
          is_expected.to contain_sensu_agent_entity_config('sensu::agent::subscription apache').with({
            'config'    => 'subscriptions',
            'value'     => 'foo',
            'entity'    => 'localhost',
            'namespace' => 'default',
          })
        }
      end
    end
  end
end
