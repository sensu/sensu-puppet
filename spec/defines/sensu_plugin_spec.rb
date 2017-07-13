require 'spec_helper'

describe 'sensu::plugin', :type => :define do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    class { '::sensu':
      manage_plugins_dir => false,
    }
    ENDofPUPPETcode
  end

  context 'file' do
    let(:title) { 'puppet:///data/plug1' }

    context 'defaults' do

      it { should contain_file('/etc/sensu/plugins/plug1').with(
        :source => 'puppet:///data/plug1'
      ) }
    end

    context 'setting params' do
      let(:params) { {
        :install_path => '/var/sensu/plugins',
      } }

      it { should contain_file('/var/sensu/plugins/plug1').with(
        :source => 'puppet:///data/plug1'
      ) }
    end
  end #file

  context 'url' do
    let(:title) { 'https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh' }

    context 'defaults' do
      let(:params) { {
        :type         => 'url',
        :pkg_checksum => '1d58b78e9785f893889458f8e9fe8627'
      } }

      it { should contain_remote_file('https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh').with(
        :ensure   => 'present',
        :path     => '/etc/sensu/plugins/check-mem.sh',
        :checksum => '1d58b78e9785f893889458f8e9fe8627'
      ) }

    end

    context 'setting params' do
      let(:params) { {
        :type         => 'url',
        :install_path => '/var/sensu/plugins',
        :pkg_checksum => '1d58b78e9785f893889458f8e9fe8627'
      } }

      it { should contain_remote_file('https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh').with(
        :ensure   => 'present',
        :path     => '/var/sensu/plugins/check-mem.sh',
        :checksum => '1d58b78e9785f893889458f8e9fe8627'
      ) }

    end

    context 'new plugin should provide source' do
      let(:title) { 'https://raw.githubusercontent.com/sensu-plugins/sensu-plugins-puppet/master/bin/check-puppet-last-run.rb' }
      let(:params) { {
        :type         => 'url',
        :install_path => '/var/sensu/plugins',
      } }

      it { should contain_remote_file('https://raw.githubusercontent.com/sensu-plugins/sensu-plugins-puppet/master/bin/check-puppet-last-run.rb').with(
        :ensure   => 'present',
        :path     => '/var/sensu/plugins/check-puppet-last-run.rb',
        :source   => 'https://raw.githubusercontent.com/sensu-plugins/sensu-plugins-puppet/master/bin/check-puppet-last-run.rb'
      ) }

    end

  end #url

  context 'directory' do
    let(:title) { 'puppet:///data/sensu/plugins' }

    context 'defaults' do
      let(:params) { { :type => 'directory' } }

      it { should contain_file('/etc/sensu/plugins_for_plugin_puppet:///data/sensu/plugins').with(
        'source'  => 'puppet:///data/sensu/plugins',
        'path'    => '/etc/sensu/plugins',
        'ensure'  => 'directory',
        'recurse' => 'true',
        'force'   => 'true',
        'purge'   => 'true'
      ) }
    end

    context 'set install_path' do
      let(:params) { { :type => 'directory', :install_path => '/opt/sensu/plugins' } }

      it { should contain_file('/opt/sensu/plugins_for_plugin_puppet:///data/sensu/plugins').with(
        'path' => '/opt/sensu/plugins',
      ) }
    end

    context 'set purge params' do
      let(:params) { { :type => 'directory', :recurse => false, :force => false, :purge => false } }

      it { should contain_file('/etc/sensu/plugins_for_plugin_puppet:///data/sensu/plugins').with(
        'recurse' => false,
        'purge'   => false,
        'force'   => false,
        'mode'    => '0555',
        'owner'   => 'sensu',
        'group'   => 'sensu'
      ) }
    end
  end #directory

  context 'package' do
    let(:title) { 'sensu-plugins' }

    context 'default' do
      let(:params) { { :type => 'package' } }

      it { should contain_package('sensu-plugins').with_ensure('latest') }

      it do
        should contain_package('sensu-plugins').with({
          'ensure'          => 'latest',
          'provider'        => nil,
          'install_options' => nil,
        })
      end
    end

    context 'set pkg_version' do
      let(:params) { { :type => 'package', :pkg_version => '1.1.1' } }

      it { should contain_package('sensu-plugins').with_ensure('1.1.1') }
    end

    context 'set pkg_provider' do
      let(:params) { { :type => 'package', :pkg_provider => 'sensu_gem' } }

      it { should contain_package('sensu-plugins').with_provider('sensu_gem') }
    end

    context 'without pkg_provider set' do
      let(:params) { { :type => 'package' } }

      it { should contain_package('sensu-plugins').with_provider(nil) }
    end

    # without pkg_provider => gem gem_install_options will be ignored
    context 'set gem_install_options' do
      let(:params) { { :type => 'package', :gem_install_options => [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }] } }
      it { should contain_package('sensu-plugins').with_install_options(nil) }
    end

    context 'set gem_install_options and pkg_provider = gem' do
      let(:params) { { :type => 'package', :gem_install_options => [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }], :pkg_provider => 'gem' } }
      it { should contain_package('sensu-plugins').with_install_options([{ '-p' => 'http://user:pass@myproxy.company.org:8080' }]) }
    end

  end #package

  context 'default' do
    let(:params) { { :type => 'unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end #default

end
