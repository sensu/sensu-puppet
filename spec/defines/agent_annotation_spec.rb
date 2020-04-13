require 'spec_helper'

describe 'sensu::agent::annotation' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node) { 'localhost' }
      let(:title) { 'cpu.title' }
      let(:params) { { :value => 'foo' } }

      it {
        is_expected.to contain_datacat_fragment('sensu_agent_config-annotation-cpu.title').with({
          'target' => 'sensu_agent_config',
          'data'   => {
            'annotations' => { 'cpu.title' => 'foo' },
          },
          'order'  => '50',
        })
      }

      it { is_expected.not_to contain_sensu__agent__config_entry('redact-annotation-cpu.title') }

      context 'redact' do
        let(:params) { { :redact => true, :value => 'foo' } }
        it {
          is_expected.to contain_sensu__agent__config_entry('redact-annotation-cpu.title').with({
            'key'   => 'redact',
            'value' => ['cpu.title'],
          })
        }
      end

      context 'all params' do
        let(:params) do
          {
            :value  => '90',
            :key    => 'cpu.critical',
            :order  => '01',
          }
        end
        it {
          is_expected.to contain_datacat_fragment('sensu_agent_config-annotation-cpu.title').with({
            'target' => 'sensu_agent_config',
            'data'   => {
              'annotations' => { 'cpu.critical' => '90' },
            },
            'order'  => '01',
          })
        }
      end
    end
  end
end
