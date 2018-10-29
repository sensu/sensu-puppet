require 'spec_helper'

describe 'sensu::repo', :type => :class do
  on_supported_os({facterversion: '3.8.0'}).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      case os
      when /(redhat-6|centos-6|amazon-2017|amazon-2018)-x86_64/
        baseurl = "https://packagecloud.io/sensu/beta/el/6/$basearch"
      when /(redhat-7|centos-7|amazonlinux-2)-x86_64/
        baseurl = "https://packagecloud.io/sensu/beta/el/7/$basearch"
      else
        baseurl = nil
      end
      if facts[:osfamily] == 'RedHat'
        it {
          should contain_yumrepo('sensu').with({
            'descr'           => 'sensu',
            'baseurl'         => baseurl,
            'repo_gpgcheck'   => 1,
            'gpgcheck'        => 0,
            'enabled'         => 1,
            'gpgkey'          => 'https://packagecloud.io/sensu/beta/gpgkey',
            'sslverify'       => 1,
            'sslcacert'       => '/etc/pki/tls/certs/ca-bundle.crt',
            'metadata_expire' => 300,
          })
        }
      elsif facts[:osfamily] == 'Debian'
        it {
          should contain_apt__source('sensu').with({
            'ensure' => 'present',
            'location' => "https://packagecloud.io/sensu/beta/#{facts[:os]['name'].downcase}/",
            'repos'    => 'main',
            'release'  => facts[:os]['distro']['codename'],
            'include'  => { 'src' => 'true' },
            'key'      => {
              'id'     => '0B3B86AFEF2D99B085BEDC6A4263180AAE8AAE03',
              'source' => 'https://packagecloud.io/sensu/beta/gpgkey',
            },
          })
        }
      end
    end
  end
end

