require 'spec_helper'

describe 'sensu::ssl', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        # Unknown bug in rspec-puppet fails to compile windows paths
        # when they are used for file source of sensu_ssl_ca, issue with windows mocking
        # https://github.com/rodjek/rspec-puppet/issues/750
        if facts[:os]['family'] != 'windows'
          it { should compile }
        end

        it { should create_class('sensu::ssl') }
        it { should contain_class('sensu') }

        it {
          should contain_file('sensu_ssl_dir').with({
            'ensure'  => 'directory',
            'path'    => platforms[facts[:osfamily]][:ssl_dir],
            'purge'   => true,
            'recurse' => true,
            'force'   => true,
            'owner'   => platforms[facts[:osfamily]][:user],
            'group'   => platforms[facts[:osfamily]][:group],
            'mode'    => platforms[facts[:osfamily]][:ssl_dir_mode],
          })
        }

        it {
          should contain_file('sensu_ssl_ca').with({
            'ensure'    => 'file',
            'path'      => platforms[facts[:osfamily]][:ca_path],
            'owner'     => platforms[facts[:osfamily]][:user],
            'group'     => platforms[facts[:osfamily]][:group],
            'mode'      => platforms[facts[:osfamily]][:ca_mode],
            'show_diff' => 'false',
            'source'    => facts['puppet_localcacert'],
          })
        }
      end
    end
  end
end

