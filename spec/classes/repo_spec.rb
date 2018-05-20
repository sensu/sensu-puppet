require 'spec_helper'

describe 'sensu::repo', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      context 'sensu::repo yumrepo', :if => facts['osfamily'] == 'RedHat' do
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

