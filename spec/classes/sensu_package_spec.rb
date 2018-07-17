require 'spec_helper'

describe 'sensu' do
  let(:facts) do
    {
      :fqdn                      => 'testhost.domain.com',
      :kernel                    => 'Linux',
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => 7,
    }
  end

  directories = [ '/etc/sensu/conf.d', '/etc/sensu/conf.d/handlers', '/etc/sensu/conf.d/checks',
        '/etc/sensu/handlers', '/etc/sensu/extensions', '/etc/sensu/mutators',
        '/etc/sensu/extensions/handlers', '/etc/sensu/plugins' ]

  context 'package' do
    context 'defaults' do
      it { should create_class('sensu::package') }
      it { should contain_package('sensu').with_ensure('installed') }
      it { should contain_file('/etc/default/sensu') }
      it { should contain_file('/etc/default/sensu').with_content(%r{^EMBEDDED_RUBY=true$}) }
      it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_LEVEL=info$}) }
      it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_DIR=/var/log/sensu$}) }
      it { should contain_file('/etc/default/sensu').without_content(%r{^RUBYOPT=.*$}) }
      it { should contain_file('/etc/default/sensu').without_content(%r{^GEM_PATH=.*$}) }
      it { should contain_file('/etc/default/sensu').without_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=.*$}) }
      it { should contain_file('/etc/default/sensu').with_content(%r{^SERVICE_MAX_WAIT="10"$}) }
      it { should contain_file('/etc/default/sensu').with_content(%r{^PATH=\$PATH$}) }
      it { should contain_file('/etc/default/sensu').without_content(%r{^CONFD_DIR=.*$}) }
      it { should contain_file('/etc/default/sensu').without_content(%r{^HEAP_SIZE=.*$}) }
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
      context 'without platform version suffix' do
        let(:params) { {
          :version              => '0.29.0',
          :sensu_plugin_version => 'installed',
        } }

        it { should contain_package('sensu').with(
          :ensure => '0.29.0'
        ) }

        it { should contain_package('sensu-plugin').with(
          :ensure   => 'installed',
        ) }
      end

      context 'with redhat platform version suffix' do
        let(:params) { {
          :version              => '0.29.0-1.el7',
          :sensu_plugin_version => 'installed',
        } }

        it { should contain_package('sensu').with(
          :ensure => '0.29.0-1.el7'
        ) }

        it { should contain_package('sensu-plugin').with(
          :ensure   => 'installed',
        ) }
      end
    end

    describe 'embeded_ruby' do
      context 'with default behavior (GH-688)' do
        it { should contain_package('sensu-plugin').with(:provider => 'sensu_gem') }
      end

      context 'with use_embedded_ruby => true' do
        let(:params) { { :use_embedded_ruby => true } }

        it { should contain_package('sensu-plugin').with(:provider => 'sensu_gem') }
      end

      context 'with use_embedded_ruby => false' do
        let(:params) { { :use_embedded_ruby => false } }

        it { should contain_package('sensu-plugin').with(:provider => 'gem') }
      end
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
        let(:facts) do
          {
            :kernel          => 'Linux',
            :osfamily        => 'Debian',
            :lsbdistid       => 'ubuntu',
            :lsbdistcodename => 'trusty',
            :lsbdistrelease  => '14.04',
            :os              => {
              :name    => 'ubuntu',
              :release => {
                :full => '14.04'
              },
              :distro => {
                :codename => 'trusty',
              },
            },
          }
        end

        context 'with puppet-apt installed' do
          let(:pre_condition) { [ 'define apt::source ($ensure, $location, $release, $repos, $include, $key) {}' ] }

          context 'default' do
            it { should contain_apt__source('sensu').with(
              :ensure      => 'present',
              :location    => 'https://sensu.global.ssl.fastly.net/apt',
              :release     => 'trusty',
              :repos       => 'main',
              :include     => { 'src' => false },
              :key         => { 'id' => 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB', 'source' => 'https://sensu.global.ssl.fastly.net/apt/pubkey.gpg' },
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

      context 'Debian' do
        context '8 (jessie)' do
          let(:facts) do
            {
              :kernel          => 'Linux',
              :osfamily        => 'Debian',
              :lsbdistid       => 'Debian',
              :lsbdistcodename => 'jessie',
              :lsbdistrelease  => '8.6',
              :os => {
                :name    => 'Debian',
                :release => {
                  :full => '8.6',
                },
                :distro => {
                  :codename => 'jessie',
                },
              },
            }
          end

          context 'repo release' do
            it { should contain_apt__source('sensu').with(
              :ensure      => 'present',
              :location    => 'https://sensu.global.ssl.fastly.net/apt',
              :release     => 'jessie',
              :repos       => 'main',
              :include     => { 'src' => false },
              :key         => { 'id' => 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB', 'source' => 'https://sensu.global.ssl.fastly.net/apt/pubkey.gpg' },
              :before      => 'Package[sensu]'
            ) }
          end
        end

        context '9 (stretch)' do
          let(:facts) do
            {
              :kernel          => 'Linux',
              :osfamily        => 'Debian',
              :lsbdistid       => 'Debian',
              :lsbdistcodename => 'stretch',
              :lsbdistrelease  => '9.3',
              :os => {
                :name    => 'Debian',
                :release => {
                  :full => '9.3',
                },
                :distro => {
                  :codename => 'stretch',
                },
              },
            }
          end

          context 'repo release' do
            it { should contain_apt__source('sensu').with(
              :ensure      => 'present',
              :location    => 'https://sensu.global.ssl.fastly.net/apt',
              :release     => 'stretch',
              :repos       => 'main',
              :include     => { 'src' => false },
              :key         => { 'id' => 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB', 'source' => 'https://sensu.global.ssl.fastly.net/apt/pubkey.gpg' },
              :before      => 'Package[sensu]'
            ) }
          end
        end

        context 'with repo_release specified' do
          let(:facts) do
            {
              :kernel          => 'Linux',
              :osfamily        => 'Debian',
              :lsbdistid       => 'Debian',
              :lsbdistrelease  => '9.3',
              :os => {
                :name    => 'Debian',
                :release => {
                  :full => '9.3',
                },
                :distro => {
                  :codename => 'wheezy',
                },
              },
            }
          end
          let(:params) { { :repo_release => 'myrelease' } }

          context 'repo release' do
            it { should contain_apt__source('sensu').with(
              :release => 'myrelease',
            ) }
          end
        end
      end

      context 'RedHat' do
        let(:facts) do
          {
            :kernel   => 'Linux',
            :osfamily => 'RedHat',
          }
        end

        context 'default' do
          it { should contain_yumrepo('sensu').with(
            :enabled   => 1,
            :baseurl   => 'https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch/',
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
          it { should contain_yumrepo('sensu').with(:baseurl => 'https://sensu.global.ssl.fastly.net/yum-unstable/$releasever/$basearch/' )}
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
          expect { should create_class('sensu') }.to raise_error(Puppet::PreformattedError)
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

    context 'on Windows 2012r2' do
      let(:facts) do
        {
          :fqdn            => 'testhost.domain.com',
          :operatingsystem => 'Windows',
          :kernel          => 'windows',
          :osfamily        => 'windows',
          :os              => {
            :architecture => 'x64',
            :release => {
              :major => '2012 R2',
            },
          },
        }
      end

      context 'with defaults (GH-646)' do
        it { should_not contain_package('Sensu') }
        it { should contain_package('sensu').with(
          ensure: 'installed',
          source: 'C:\\Windows\\Temp\\sensu-latest.msi',
        ) }

        it { should contain_remote_file('sensu').with(
          source: 'https://repositories.sensuapp.org/msi/2012r2/sensu-latest-x64.msi',
          path: 'C:\\Windows\\Temp\\sensu-latest.msi',
        ) }
      end

      context 'with explicit version, as used by Vagrant  (GH-646)' do
        let(:params) { { version: '0.29.0-11' } }
        it { should contain_remote_file('sensu').with(
          source: 'https://repositories.sensuapp.org/msi/2012r2/sensu-0.29.0-11-x64.msi',
        ) }
        # The MSI provider will keep re-installing the package unless the
        # version is translated into dotted form.  e.g. 'Notice:
        # /Stage[main]/Sensu::Package/Package[sensu]/ensure: ensure changed
        # '0.29.0.11' to '0.29.0-11'
        it 'translates 0.29.0-11 to 0.29.0.11' do
          should contain_package('sensu').with(ensure: '0.29.0.11')
        end
        # The MSI provider checks Add/Remove programs.  Package[sensu] is
        # registered as "Sensu" so the name parameter must match.
        it 'uses name "Sensu" to match Add/Remove Programs' do
          should contain_package('sensu').with(name: 'Sensu')
        end
      end

      context 'with windows_pkg_url specified' do
        let(:params) do
          { windows_pkg_url: 'https://repositories.sensuapp.org/msi/2012r2/sensu-0.29.0-11-x64.msi' }
        end

        it 'overrides computation using windows_repo_prefix' do
          should contain_remote_file('sensu').with(
            source: 'https://repositories.sensuapp.org/msi/2012r2/sensu-0.29.0-11-x64.msi'
          )
        end
      end

      context 'with sensu::windows_package_provider: chocolatey' do
        let(:params) do
          { windows_package_provider: 'chocolatey' }
        end
        it 'uses the chocolatey provider for Package[Sensu]' do
          should contain_package('sensu').with(provider: 'chocolatey')
        end
      end
    end
  end

  context 'with use_embedded_ruby => false' do
    let(:params) { {:use_embedded_ruby => false } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^EMBEDDED_RUBY=false$}) }
  end

  context 'with log_level => debug' do
    let(:params) { {:log_level => 'debug' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_LEVEL=debug$}) }
  end

  context 'with log_dir => /var/log/tests' do
    let(:params) { {:log_dir => '/var/log/tests' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_DIR=/var/log/tests$}) }
  end

  context 'rubyopt => -rbundler/test' do
    let(:params) { {:rubyopt => '-rbundler/test' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^RUBYOPT="-rbundler/test"$}) }
  end

  context 'gem_path => /path/to/gems' do
    let(:params) { {:gem_path => '/path/to/gems' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^GEM_PATH="/path/to/gems"$}) }
  end

  context 'deregister_on_stop => true' do
    let(:params) { {:deregister_on_stop => true } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=""$}) }
  end

  # without deregister_on_stop == true deregister_handler will be ignored
  context 'deregister_handler => testing' do
    let(:params) { {:deregister_handler => 'testing' } }
    it { should contain_file('/etc/default/sensu').without_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=.*$}) }
  end

 context 'deregister_on_stop => true & deregister_handler => testing' do
    let(:params) { {:deregister_on_stop => true, :deregister_handler => 'testing' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER="testing"$}) }
  end

  context 'init_stop_max_wait => 242' do
    let(:params) { {:init_stop_max_wait => 242 } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^SERVICE_MAX_WAIT="242"$}) }
  end

  context 'path => /spec/tests' do
    let(:params) { {:path => '/spec/tests' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^PATH=/spec/tests$}) }
  end

  context 'confd_dir => /spec/tests' do
    let(:params) { {:confd_dir => '/spec/tests' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CONFD_DIR="/etc/sensu/conf\.d,/spec/tests"$}) }
  end

  context 'confd_dir => [/spec/tests,/more/tests]' do
    let(:params) { {:confd_dir => ['/spec/tests', '/more/tests'] } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CONFD_DIR="/etc/sensu/conf\.d,/spec/tests,/more/tests"$}) }
  end

  context 'heap_size => 256' do
    let(:params) { {:heap_size => 256 } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^HEAP_SIZE="256"$}) }
  end

  context 'heap_size => "256M"' do
    let(:params) { {:heap_size => '256M' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^HEAP_SIZE="256M"$}) }
  end

  context 'config_file => "/etc/sensu/alternative.json"' do
    let(:params) { {:config_file => '/etc/sensu/alternative.json' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CONFIG_FILE="/etc/sensu/alternative.json"$}) }
  end

  describe 'spawn_limit (#727)' do
    context 'default (undef)' do
      it { should contain_file('/etc/sensu/conf.d/spawn.json').without_content }
    end
    context '=> 20' do
      let(:params) { {spawn_limit: 20} }
      it { should contain_file('/etc/sensu/conf.d/spawn.json').with_content(/limit.*20/) }
    end
  end
end
