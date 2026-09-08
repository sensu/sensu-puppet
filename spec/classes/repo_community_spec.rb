require 'spec_helper'

describe 'sensu::repo::community', :type => :class do
  on_supported_os.each do |os, facts|
    # This class not used by Windows
    if facts[:os]['family'] == 'windows'
      next
    end
    context "on #{os}" do
      let(:facts) { facts }
      makecache = false
      case os
      when /(redhat-6|centos-6|amazon-201\d)-x86_64/
        baseurl = "https://packagecloud.io/sensu/community/el/6/$basearch"
      when /(redhat-7|centos-7|amazon-2023)-x86_64/
        # manifests/repo/community.pp's Amazon handling predates the amazon-2023 addition
        # elsewhere (unlike repo.pp) and still falls through to el/7 here -- matching that
        # actual current behavior, not fixing the underlying manifest, since this whole
        # class is deleted in the follow-up plugin-removal PR.
        baseurl = "https://packagecloud.io/sensu/community/el/7/$basearch"
      when /(redhat-8|centos-8|rocky-8|almalinux-8)-x86_64/
        baseurl = "https://packagecloud.io/sensu/community/el/8/$basearch"
        makecache = true
      when /(redhat-9|centos-9|rocky-9|almalinux-9)-x86_64/
        baseurl = "https://packagecloud.io/sensu/community/el/9/$basearch"
      else
        baseurl = nil
      end
      it { should compile.with_all_deps }
      if facts[:os]['family'] == 'RedHat'
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
        if makecache
          it {
            should contain_exec('dnf makecache sensu_community').with({
              'path'        => '/usr/bin:/bin:/usr/sbin:/sbin',
              'command'     => "dnf -q makecache -y --disablerepo='*' --enablerepo='sensu_community'",
              'refreshonly' => 'true',
              'tries'       => '2',
              'subscribe'   => 'Yumrepo[sensu_community]',
            })
          }
        else
          it { should_not contain_exec('dnf makecache sensu') }
        end
      elsif facts[:os]['family'] == 'Debian'
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

