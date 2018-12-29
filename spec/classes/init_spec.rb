require 'spec_helper'

describe 'sensu', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        it { should compile }

        it { should contain_class('sensu')}
        it { should contain_class('sensu::repo')}

        it {
          should contain_file('sensu_etc_dir').with({
            'ensure'  => 'directory',
            'path'    => '/etc/sensu',
            'purge'   => true,
            'recurse' => true,
          })
        }
      end
    end
  end
end

