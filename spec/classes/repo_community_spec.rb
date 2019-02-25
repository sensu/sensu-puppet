require 'spec_helper'

describe 'sensu::repo::community', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      case os
      when /(redhat-6|centos-6|amazon-2017|amazon-2018)-x86_64/
        baseurl = "https://packagecloud.io/sensu/community/el/6/$basearch"
      when /(redhat-7|centos-7|amazon-2)-x86_64/
        baseurl = "https://packagecloud.io/sensu/community/el/7/$basearch"
      else
        baseurl = nil
      end
      if facts[:osfamily] == 'RedHat'
        it {
          should contain_yumrepo('sensu_community').with({
            'descr'           => 'sensu_community',
            'baseurl'         => baseurl,
            'repo_gpgcheck'   => 1,
            'gpgcheck'        => 0,
            'enabled'         => 1,
            'gpgkey'          => 'https://packagecloud.io/sensu/community/gpgkey',
            'sslverify'       => 1,
            'sslcacert'       => '/etc/pki/tls/certs/ca-bundle.crt',
            'metadata_expire' => 300,
          })
        }
      elsif facts[:osfamily] == 'Debian'
        it {
          should contain_apt__source('sensu_community').with({
            'ensure' => 'present',
            'location' => "https://packagecloud.io/sensu/community/#{facts[:os]['name'].downcase}/",
            'repos'    => 'main',
            'release'  => facts[:os]['distro']['codename'],
            'include'  => { 'src' => 'true' },
            'key'      => {
              'id'     => '7F54E8A5C0CB51DBE612D2F50156BD72FEC8CD59',
              'source' => 'https://packagecloud.io/sensu/community/gpgkey',
            },
          })
        }
      end
    end
  end
end

