require 'spec_helper'

describe 'sensu::backend::tessen', :type => :class do
  on_supported_os({
    facterversion: '3.8.0',
    supported_os: [{ 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['7'] }]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'default (present)' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::backend': }
          EOS
        end
        it { should compile.with_all_deps }
        it do
          should contain_exec('sensuctl tessen opt-in').with({
            :path => '/usr/bin:/bin:/usr/sbin:/sbin',
            :onlyif   => "sensuctl tessen info --format json | grep 'opt_out' | grep -q true",
            :require  => [
              'Sensuctl_configure[puppet]',
              'Sensu_user[admin]',
            ]
          })
        end
      end
      context 'opt-out (absent)' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::backend':
            tessen_ensure => 'absent',
          }
          EOS
        end
        it { should compile.with_all_deps }
        it do
          should contain_exec('sensuctl tessen opt-out --skip-confirm').with({
            :path => '/usr/bin:/bin:/usr/sbin:/sbin',
            :onlyif   => "sensuctl tessen info --format json | grep 'opt_out' | grep -q false",
            :require  => [
              'Sensuctl_configure[puppet]',
              'Sensu_user[admin]',
            ]
          })
        end
      end
    end
  end
end
