require 'spec_helper'

describe 'sensu' do
  let(:facts) { { :fqdn => 'testhost.domain.com' } }

  context 'package' do
    context 'defaults' do
      it { should create_class('sensu::package') }
      it { should contain_package('sensu').with_ensure('latest') }
      it { should contain_file('/etc/default/sensu') }
      [ '/etc/sensu/conf.d', '/etc/sensu/conf.d/handlers', '/etc/sensu/conf.d/checks' ].each do |dir|
        it { should contain_file(dir).with(
          :ensure => 'directory',
          :purge  => false
        ) }
      end
      it { should contain_file('/etc/sensu/config.json').with_ensure('absent') }
      it { should contain_user('sensu') }
      it { should contain_group('sensu') }
    end

    context 'setting version' do
      let(:params) { {
        :version              => '0.9.10',
        :sensu_plugin_version => 'installed',
      } }

      it { should contain_package('sensu').with(
        :ensure => '0.9.10'
      ) }

      it { should contain_package('sensu-plugin').with(
        :ensure   => 'installed',
        :provider => 'gem'
      ) }
    end

    context 'repos' do

      context 'ubuntu' do
        let(:facts) { { :osfamily => 'Debian' } }

        context 'with puppet-apt installed' do
          let(:pre_condition) { [ 'define apt::source ($ensure, $location, $release, $repos, $include_src, $key, $key_source) {}' ] }

          context 'default' do
            it { should contain_apt__source('sensu').with(
              :ensure      => 'present',
              :location    => 'http://repos.sensuapp.org/apt',
              :release     => 'sensu',
              :repos       => 'main',
              :include_src => false,
              :key         => '7580C77F',
              :key_source  => 'http://repos.sensuapp.org/apt/pubkey.gpg',
              :before      => 'Package[sensu]'
            ) }
          end

          context 'unstable repo' do
            let(:params) { { :repo => 'unstable' } }
            it { should contain_apt__source('sensu').with_repos('unstable') }
          end

          context 'override repo url' do
            let(:params) { { :repo_source => 'http://repo.mydomain.com/apt' } }
            it { should contain_apt__source('sensu').with( :location => 'http://repo.mydomain.com/apt') }

            it { should_not contain_apt__key('sensu').with(
              :key         => '7580C77F',
              :key_source  => 'http://repo.mydomain.com/apt/pubkey.gpg'
            ) }
          end

          context 'override key ID and key source' do
            let(:params) { { :repo_key_id => 'FFFFFFFF', :repo_key_source => 'http://repo.mydomina.com/apt/pubkey.gpg' } }

            it { should_not contain_apt__key('sensu').with(
              :key         => 'FFFFFFFF',
              :key_source  => 'http://repo.mydomain.com/apt/pubkey.gpg'
            ) }
          end

          context 'install_repo => false' do
            let(:params) { { :install_repo => false, :repo => 'main' } }
            it { should contain_apt__source('sensu').with_ensure('absent') }

            it { should_not contain_apt__key('sensu').with(
              :key         => '7580C77F',
              :key_source  => 'http://repos.sensuapp.org/apt/pubkey.gpg'
            ) }

            it { should contain_package('sensu').with( :require => nil ) }
          end
        end

        context 'without puppet-apt installed' do
          it { expect { should raise_error(Puppet::Error) } }
        end
      end

      context 'redhat' do
        let(:facts) { { :osfamily => 'RedHat', :operatingsystemmajrelease => '6' } }

        context 'default' do
          it { should contain_yumrepo('sensu').with(
            :enabled   => 1,
            :baseurl   => 'http://repos.sensuapp.org/yum/el/6/$basearch/',
            :gpgcheck  => 0,
            :before    => 'Package[sensu]'
          ) }
        end

        context 'unstable repo' do
          let(:params) { { :repo => 'unstable' } }
          it { should contain_yumrepo('sensu').with(:baseurl => 'http://repos.sensuapp.org/yum-unstable/el/6/$basearch/' )}
        end

        context 'override repo url' do
          let(:params) { { :repo_source => 'http://repo.mydomain.com/yum' } }
          it { should contain_yumrepo('sensu').with( :baseurl => 'http://repo.mydomain.com/yum') }
        end

        context 'install_repo => false' do
          let(:params) { { :install_repo => false } }
          it { should_not contain_yumrepo('sensu') }
          it { should contain_package('sensu').with( :require => nil ) }
        end
      end
    end

    context 'purge_config' do
      let(:params) { { :purge_config => true } }

      [ '/etc/sensu/conf.d', '/etc/sensu/conf.d/handlers', '/etc/sensu/conf.d/checks' ].each do |dir|
        it { should contain_file(dir).with(
          :ensure  => 'directory',
          :purge   => true,
          :recurse => true,
          :force   => true
        ) }
      end

    end
  end

end
