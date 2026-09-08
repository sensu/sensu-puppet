require 'spec_helper'

describe 'sensu::common', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
        end

        it { should contain_class('sensu')}
        if facts[:os]['family'] == 'windows'
          it { should_not contain_class('sensu::repo')}
        else
          it { should contain_class('sensu::repo')}
        end
        it { should contain_class('sensu::ssl') }

        if facts[:os]['family'] == 'windows'
          it { should_not contain_user('sensu') }
          it { should_not contain_group('sensu') }
        else
          it {
            should contain_user('sensu').with({
              'ensure'     => 'present',
              'name'       => 'sensu',
              'forcelocal' => true,
              'shell'      => '/bin/false',
              'gid'        => 'sensu',
              'uid'        => nil,
              'home'       => '/var/lib/sensu',
              'managehome' => 'false',
              'system'     => 'true',
            })
          }
          it {
            should contain_group('sensu').with({
              'ensure'     => 'present',
              'name'       => 'sensu',
              'forcelocal' => 'true',
              'gid'        => nil,
              'system'     => 'true',
            })
          }
        end

        if platforms[facts[:os]['family']][:etc_parent_dir]
          it {
            should contain_file('sensu_dir').with({
              'ensure'  => 'directory',
              'path'    => platforms[facts[:os]['family']][:etc_parent_dir],
              'owner'   => platforms[facts[:os]['family']][:user],
              'group'   => platforms[facts[:os]['family']][:group],
              'mode'    => platforms[facts[:os]['family']][:etc_dir_mode],
            })
          }
        else
          it { should_not contain_file('sensu_dir') }
        end

        it {
          should contain_file('sensu_etc_dir').with({
            'ensure'  => 'directory',
            'path'    => platforms[facts[:os]['family']][:etc_dir],
            'owner'   => platforms[facts[:os]['family']][:user],
            'group'   => platforms[facts[:os]['family']][:group],
            'mode'    => platforms[facts[:os]['family']][:etc_dir_mode],
            'purge'   => true,
            'recurse' => true,
            'force'   => true,
          })
        }
      end

      context 'when manage_user => false' do
        let(:pre_condition) { "class { 'sensu': manage_user => false }" }
        it { should_not contain_user('sensu') }
      end

      context 'when manage_group => false' do
        let(:pre_condition) { "class { 'sensu': manage_group => false }" }
        it { should_not contain_group('sensu') }
      end

      context 'with use_ssl => false' do
        let(:pre_condition) { "class { 'sensu': use_ssl => false }" }
        # See the compile check near the top of this file — same rspec-puppet
        # Windows path-mocking limitation.
        if facts[:os]['family'] != 'windows'
          it { should compile.with_all_deps }
        end
        it { should_not contain_class('sensu::ssl') }
      end
    end
  end
end

