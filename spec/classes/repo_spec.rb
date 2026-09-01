require 'spec_helper'

describe 'sensu::repo', :type => :class do
  on_supported_os.each do |os, facts|
    # repo class not used for Windows
    if facts[:os]['family'] == 'windows'
      next
    end
    context "on #{os}" do
      let(:facts) { facts }
      el8 = false
      case os
      when /(redhat-7|centos-7)-x86_64/
        baseurl = "https://packagecloud.io/sensu/stable/el/7/$basearch"
      when /amazon-2023-x86_64/
        baseurl = "https://packagecloud.io/sensu/stable/el/9/$basearch"
      when /(redhat-8|centos-8|rocky-8|almalinux-8)-x86_64/
        baseurl = nil
        el8 = true
      else
        baseurl = nil
      end
      it { should compile.with_all_deps }
      if facts[:osfamily] == 'RedHat'
        if el8
          it { should_not contain_yumrepo('sensu') }
          it { should_not contain_exec('dnf makecache sensu') }
          it {
            should contain_package('curl').with({
              'ensure' => 'installed',
            })
          }
          it {
            should contain_exec('install sensu repository').with({
              'path'    => '/usr/bin:/bin:/usr/sbin:/sbin',
              'command' => 'curl -s https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | bash',
              'unless'  => 'dnf repolist | grep -q sensu',
              'require' => 'Package[curl]',
            })
          }
          it {
            should contain_exec('disable sensu gpg check').with({
              'path'    => '/usr/bin:/bin:/usr/sbin:/sbin',
              'command' => 'sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/sensu_stable.repo',
              'unless'  => 'grep -q "gpgcheck=0" /etc/yum.repos.d/sensu_stable.repo',
              'require' => 'Exec[install sensu repository]',
              'notify'  => 'Exec[refresh sensu repository cache]',
            })
          }
          it {
            should contain_exec('refresh sensu repository cache').with({
              'path'        => '/usr/bin:/bin:/usr/sbin:/sbin',
              'command'     => 'dnf makecache',
              'refreshonly' => 'true',
            })
          }
        else
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

