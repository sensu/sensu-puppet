require 'spec_helper'

describe 'sensu::plugin', :type => :define do
  # let(:facts) { { :osfamily => 'RedHat' } }
  # let(:pre_condition) { 'class {"sensu": manage_plugins_dir => false' }
  let(:pre_condition) { ['class sensu::client::service {}', 'include sensu::client::service'] }

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

  end #url

  context 'directory' do
    let(:title) { 'puppet:///data/sensu/plugins' }

    context 'defaults' do
      let(:params) { { :type => 'directory' } }

      it { should contain_file('/etc/sensu/plugins').with(
        'source'  => 'puppet:///data/sensu/plugins',
        'ensure'  => 'directory',
        'recurse' => 'true',
        'force'   => 'true',
        'purge'   => 'true'
      ) }
    end

    context 'set install_path' do
      let(:params) { { :type => 'directory', :install_path => '/opt/sensu/plugins' } }

      it { should contain_file('/opt/sensu/plugins') }
    end

    context 'set purge params' do
      let(:params) { { :type => 'directory', :recurse => false, :force => false, :purge => false } }

      it { should contain_file('/etc/sensu/plugins').with(
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
    end

    context 'set version' do
      let(:params) { { :type => 'package', :pkg_version => '1.1.1' } }

      it { should contain_package('sensu-plugins').with_ensure('1.1.1') }
    end

    context 'set provider' do
      let(:params) { { :type => 'package', :pkg_provider => 'sensu_gem' } }

      it { should contain_package('sensu-plugins').with_provider('sensu_gem') }
    end
  end #package

  context 'default' do
    let(:params) { { :type => 'unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end #default

end
