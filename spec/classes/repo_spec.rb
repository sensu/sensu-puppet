require 'spec_helper'

describe 'sensu::repo', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      if facts[:osfamily] == 'RedHat'
        it {
          should contain_yumrepo('sensu_nightly').with({
            'baseurl'         => "https://packagecloud.io/sensu/nightly/el/#{facts[:operatingsystemmajrelease]}/$basearch",
            'repo_gpgcheck'   => 1,
            'gpgcheck'        => 0,
            'enabled'         => 1,
            'gpgkey'          => 'https://packagecloud.io/sensu/nightly/gpgkey',
            'sslverify'       => 1,
            'sslcacert'       => '/etc/pki/tls/certs/ca-bundle.crt',
            'metadata_expire' => 300,
          })
        }
      elsif facts[:osfamily] == 'Debian'
        it {
          should contain_apt__source('sensu_nightly').with({
            'ensure' => 'present',
            'location' => "https://packagecloud.io/sensu/nightly/#{facts[:os]['name'].downcase}/",
            'repos'    => 'main',
            'release'  => facts[:os]['distro']['codename'],
            'include'  => { 'src' => 'true' },
            'key'      => {
              'id'     => 'EB17E7F42AD4720A6679044309F9A5D85A56B390',
              'source' => 'https://packagecloud.io/sensu/nightly/gpgkey',
            },
          })
        }
      end
    end
  end
end

