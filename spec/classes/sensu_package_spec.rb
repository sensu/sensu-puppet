require 'spec_helper'

describe 'sensu' do
  let(:facts) { { :fqdn => 'testhost.domain.com', :osfamily => 'RedHat' } }
  directories = [ '/etc/sensu/conf.d', '/etc/sensu/conf.d/handlers', '/etc/sensu/conf.d/checks',
        '/etc/sensu/handlers', '/etc/sensu/extensions', '/etc/sensu/mutators',
        '/etc/sensu/extensions/handlers', '/etc/sensu/plugins' ]

  context 'package' do
    context 'defaults' do
      it { should create_class('sensu::package') }
      it { should contain_package('sensu').with_ensure('latest') }
      it { should contain_file('/etc/default/sensu') }
      it { should_not contain_file('/etc/default/sensu').with(:content => /RUBYOPT/) }
      it { should_not contain_file('/etc/default/sensu').with(:content => /GEM_PATH/) }
      directories.each do |dir|
        it { should contain_file(dir).with(
          :ensure  => 'directory',
          :recurse => true,
          :force   => true,
          :purge   => false
        ) }
      end
      it { should contain_file('/etc/sensu/config.json').with_ensure('absent') }
      it { should contain_user('sensu') }
      it { should contain_group('sensu') }
      it { should contain_file('/etc/sensu/plugins').with_purge(false) }
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

    context 'embeded_ruby' do
      let(:params) { { :use_embedded_ruby => true } }

      it { should contain_package('sensu-plugin').with(:provider => 'sensu_gem') }
    end

    context 'sensu_plugin_provider and sensu_plugin_name' do
      let(:params) { { :sensu_plugin_name => 'rubygem-sensu-plugin', :sensu_plugin_provider => 'rpm' } }

      it { should contain_package('rubygem-sensu-plugin').with(:provider => 'rpm') }
    end

    context 'sysconfig settings' do
      let(:params) { { :rubyopt => 'a', :gem_path => '/foo', :deregister_on_stop => true, :deregister_handler => 'example' } }
      it { should contain_file('/etc/default/sensu').with(:content => /RUBYOPT="a"/) }
      it { should contain_file('/etc/default/sensu').with(:content => /GEM_PATH="\/foo"/) }
      it { should contain_file('/etc/default/sensu').with(:content => /CLIENT_DEREGISTER_ON_STOP=true/) }
      it { should contain_file('/etc/default/sensu').with(:content => /CLIENT_DEREGISTER_HANDLER="example"/) } 
    end

    context 'repos' do

      context 'ubuntu' do
        let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'ubuntu', :lsbdistrelease => '14.04', :lsbdistcodename => 'trusty', } }

        context 'with puppet-apt installed' do
          let(:pre_condition) { [ 'define apt::source ($ensure, $location, $release, $repos, $include, $key) {}' ] }

          context 'default' do
            it { should contain_apt__source('sensu').with(
              :ensure      => 'present',
              :location    => 'http://repositories.sensuapp.org/apt',
              :release     => 'sensu',
              :repos       => 'main',
              :include     => { 'src' => false },
              :key         => { 'id' => 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB', 'source' => 'http://repositories.sensuapp.org/apt/pubkey.gpg' },
              :before      => 'Package[sensu]'
            ) }
          end

          context 'manage_repo => false' do
            let(:params) { { :manage_repo => false, :install_repo => false } }
            it { should_not contain_apt__source('sensu') }
          end

          context 'manage_repo => false independent from install_repo ' do
            let(:params) { { :manage_repo => false , :install_repo => true } }
            it { should_not contain_apt__source('sensu') }
          end

          context 'unstable repo' do
            let(:params) { { :repo => 'unstable' } }
            it { should contain_apt__source('sensu').with_repos('unstable') }
          end

          context 'override repo url' do
            let(:params) { { :repo_source => 'http://repo.mydomain.com/apt' } }
            it { should contain_apt__source('sensu').with( :location => 'http://repo.mydomain.com/apt') }

            it { should_not contain_apt__key('sensu').with(
              :key         => { 'id' => 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB', 'source'  => 'http://repo.mydomain.com/apt/pubkey.gpg' }
            ) }
          end

          context 'override key ID and key source' do
            let(:params) { { :repo_key_id => 'FFFFFFFF', :repo_key_source => 'http://repo.mydomina.com/apt/pubkey.gpg' } }

            it { should_not contain_apt__key('sensu').with(
              :key         => { 'id' => 'FFFFFFFF', 'source'  => 'http://repo.mydomain.com/apt/pubkey.gpg' }
            ) }
          end

          context 'install_repo => false' do
            let(:params) { { :install_repo => false, :repo => 'main' } }
            it { should contain_apt__source('sensu').with_ensure('absent') }

            it { should_not contain_apt__key('sensu').with(
              :key         => 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB',
              :key_source  => 'http://repositories.sensuapp.org/apt/pubkey.gpg'
            ) }

            it { should contain_package('sensu').with( :require => nil ) }
          end
        end

        context 'without puppet-apt installed' do
          it { expect { should raise_error(Puppet::Error) } }
        end
      end

      context 'redhat' do
        let(:facts) { { :osfamily => 'RedHat' } }

        context 'default' do
          it { should contain_yumrepo('sensu').with(
            :enabled   => 1,
            :baseurl   => 'http://repositories.sensuapp.org/yum/$basearch/',
            :gpgcheck  => 0,
            :before    => 'Package[sensu]'
          ) }
        end

        context 'manage_repo => false' do
          let(:params) { { :manage_repo => false, :install_repo => false } }
          it { should_not contain_yumrepo('sensu') }
        end

        context 'manage_repo => false independent from install_repo ' do
          let(:params) { { :manage_repo => false , :install_repo => true } }
          it { should_not contain_yumrepo('sensu') }
        end

        context 'unstable repo' do
          let(:params) { { :repo => 'unstable' } }
          it { should contain_yumrepo('sensu').with(:baseurl => 'http://repositories.sensuapp.org/yum-unstable/$basearch/' )}
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

    context 'purge' do
      {
        false                    => [],
        true                     => directories,
        { 'config'   => true }   => [ '/etc/sensu/conf.d', '/etc/sensu/conf.d/handlers', '/etc/sensu/conf.d/checks' ],
        { 'plugins'  => true }   => [ '/etc/sensu/plugins' ],
        { 'handlers' => true }   => [ '/etc/sensu/handlers' ],
        { 'extensions' => true } => [ '/etc/sensu/extensions', '/etc/sensu/extensions/handlers' ],
        { 'mutators' => true }   => [ '/etc/sensu/mutators' ],
        {
          'config' => true,
          'plugins' => true
        } => [ '/etc/sensu/conf.d', '/etc/sensu/conf.d/handlers', '/etc/sensu/conf.d/mutators', '/etc/sensu/conf.d/checks', '/etc/sensu/plugins' ]
      }.each do |purge_value, purged_directories|
        context "=> #{purge_value}" do
          let(:params) { { :purge => purge_value } }

          purged_directories.each do |dir|
            it { should contain_file(dir).with(
              :ensure  => 'directory',
              :recurse => true,
              :force   => true,
              :purge   => true
            ) }
          end

          (directories - purged_directories).each do |dir|
            it { should contain_file(dir).with(
              :ensure  => 'directory',
              :recurse => true,
              :force   => true,
              :purge   => false
            ) }
          end
        end
      end

      context 'with a value that is not a boolean or hash' do
        let(:params) { { :purge => 'a_string' } }

        it 'should fail' do
          expect { should create_class('sensu') }.to raise_error(/not a Hash/)
        end
      end

      context 'with a hash with an unknown key' do
        let(:params) { { :purge => { 'other_key' => true } } }

        it 'should fail' do
          expect { should create_class('sensu') }.to raise_error(/Invalid keys for purge parameter/)
        end
      end
    end

  end

  context 'directories' do
    context 'manage handlers directory' do
      let(:params) { { :manage_handlers_dir => true } }
      it { should contain_file('/etc/sensu/handlers').with(
        :ensure => 'directory',
        :mode   => '0555',
        :owner  => 'sensu',
        :group  => 'sensu',
        :recurse => true,
        :force  => true
      ) }
    end

    context 'do not manage handlers directory' do
      let (:params) { { :manage_handlers_dir => false }}
      it { should_not contain_file('/etc/sensu/handlers') }
    end

    context 'manage mutators directory' do
      let(:params) { { :manage_mutators_dir => true } }
      it { should contain_file('/etc/sensu/mutators').with(
        :ensure => 'directory',
        :mode   => '0555',
        :owner  => 'sensu',
        :group  => 'sensu',
        :recurse => true,
        :force  => true
      ) }
    end

    context 'do not manage mutators directory' do
      let (:params) { { :manage_mutators_dir => false }}
      it { should_not contain_file('/etc/sensu/mutators') }
    end
  end
end
