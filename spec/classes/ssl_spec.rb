require 'spec_helper'

describe 'sensu::ssl', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        it { should compile }

        it { should create_class('sensu::ssl') }
        it { should contain_class('sensu') }

        it {
          should contain_file('sensu_ssl_dir').with({
            'ensure'  => 'directory',
            'path'    => '/etc/sensu/ssl',
            'purge'   => true,
            'recurse' => true,
            'force'   => true,
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0700',
          })
        }

        it {
          should contain_file('sensu_ssl_ca').with({
            'ensure'    => 'file',
            'path'      => '/etc/sensu/ssl/ca.crt',
            'owner'     => 'sensu',
            'group'     => 'sensu',
            'mode'      => '0644',
            'show_diff' => 'false',
            'source'    => '/dne/ca.pem',
          })
        }
      end
    end
  end
end

