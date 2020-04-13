require 'spec_helper'

describe 'sensu::agent::label' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'localhost' }
      let(:title) { 'cpu.warning' }
      let(:params) { { :value => '90' } }

      it {
        is_expected.to contain_datacat_fragment('sensu_agent_config-label-cpu.warning').with({
          'target' => 'sensu_agent_config',
          'data'   => {
            'labels' => { 'cpu.warning' => '90' },
          },
          'order'  => '50',
        })
      }

      context 'all params' do
        let(:params) do
          {
            :value  => '90',
            :key    => 'cpu.critical',
            :order  => '01',
          }
        end
        it {
          is_expected.to contain_datacat_fragment('sensu_agent_config-label-cpu.warning').with({
            'target' => 'sensu_agent_config',
            'data'   => {
              'labels' => { 'cpu.critical' => '90' },
            },
            'order'  => '01',
          })
        }
      end
    end
  end
end
