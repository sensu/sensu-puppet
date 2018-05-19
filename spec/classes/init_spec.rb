require 'spec_helper'

describe 'sensu', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'with default values for all parameters' do
        it { should compile }

        it { should contain_class('sensu')}
        it { should contain_class('sensu::repo')}
        it { should contain_class('sensu::agent')}

        it {
          should contain_file('sensu_etc_dir').with({
            'ensure'  => 'directory',
            'path'    => '/etc/sensu',
            'purge'   => true,
            'recurse' => true,
          })
        }
      end
      context 'sensu::repo', :if => facts['osfamily'] == 'RedHat' do
        it { should contain_class('sensu::repo::yum') }
      end

      context 'sensu::repo::yum', :if => facts['osfamily'] == 'RedHat' do
        it {
          should contain_yumrepo('sensu_nightly').with({
            'baseurl'         => 'https://packagecloud.io/sensu/nightly/el/7/$basearch',
            'repo_gpgcheck'   => 1,
            'gpgcheck'        => 0,
            'enabled'         => 1,
            'gpgkey'          => 'https://packagecloud.io/sensu/nightly/gpgkey',
            'sslverify'       => 1,
            'sslcacert'       => '/etc/pki/tls/certs/ca-bundle.crt',
            'metadata_expire' => 300,
          })
        }
      end
    end
  end
end

