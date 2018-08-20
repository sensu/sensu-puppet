require 'spec_helper'

describe 'sensu::repo', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      case os
      when /(redhat-6|centos-6|amazon-2017|amazon-2018)-x86_64/
        baseurl = "https://packagecloud.io/sensu/nightly/el/6/$basearch"
      when /(redhat-7|centos-7|amazonlinux-2)-x86_64/
        baseurl = "https://packagecloud.io/sensu/nightly/el/7/$basearch"
      else
        baseurl = nil
      end
      if facts[:osfamily] == 'RedHat'
        it {
          should contain_yumrepo('sensu').with({
            'baseurl'         => baseurl,
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
          should contain_apt__source('sensu').with({
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

