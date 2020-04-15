require 'spec_helper'

describe 'sensu::repo', :type => :class do
  on_supported_os.each do |os, facts|
    # repo class not used for Windows
    if facts[:os]['family'] == 'windows'
      next
    end
    context "on #{os}" do
      let(:facts) { facts }
      makecache = false
      case os
      when /(redhat-6|centos-6|amazon-201\d)-x86_64/
        baseurl = "https://packagecloud.io/sensu/stable/el/6/$basearch"
      when /(redhat-7|centos-7|amazon-2)-x86_64/
        baseurl = "https://packagecloud.io/sensu/stable/el/7/$basearch"
      when /(redhat-8|centos-8)-x86_64/
        baseurl = "https://packagecloud.io/sensu/stable/el/8/$basearch"
        makecache = true
      else
        baseurl = nil
      end
      it { should compile.with_all_deps }
      if facts[:osfamily] == 'RedHat'
        it {
          should contain_yumrepo('sensu').with({
            'descr'           => 'sensu',
            'baseurl'         => baseurl,
            'repo_gpgcheck'   => 1,
            'gpgcheck'        => 0,
            'enabled'         => 1,
            'gpgkey'          => 'https://packagecloud.io/sensu/stable/gpgkey',
            'sslverify'       => 1,
            'sslcacert'       => '/etc/pki/tls/certs/ca-bundle.crt',
            'metadata_expire' => 300,
          })
        }
        if makecache
          it {
            should contain_exec('dnf makecache sensu').with({
              'path'        => '/usr/bin:/bin:/usr/sbin:/sbin',
              'command'     => "dnf -q makecache -y --disablerepo='*' --enablerepo='sensu'",
              'refreshonly' => 'true',
              'tries'       => '2',
              'subscribe'   => 'Yumrepo[sensu]',
            })
          }
        else
          it { should_not contain_exec('dnf makecache sensu') }
        end
      elsif facts[:osfamily] == 'Debian'
        it {
          should contain_apt__source('sensu').with({
            'ensure' => 'present',
            'location' => "https://packagecloud.io/sensu/stable/#{facts[:os]['name'].downcase}/",
            'repos'    => 'main',
            'release'  => facts[:os]['distro']['codename'],
            'include'  => { 'src' => 'true' },
            'key'      => {
              'id'     => 'CB1605C4E988C91F438249E3A5BC3FB70A3F7426',
              'source' => 'https://packagecloud.io/sensu/stable/gpgkey',
            },
          })
        }
      end
    end
  end
end

