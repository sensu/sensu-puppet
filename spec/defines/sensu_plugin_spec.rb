require 'spec_helper'

describe 'sensu::plugin', :type => :define do

  context 'file' do
    let(:title) { 'puppet:///data/plug1' }

    context 'defaults' do

      it { should contain_file('/etc/sensu/plugins/plug1').with(
        'source'      => 'puppet:///data/plug1'
      ) }
    end

    context 'setting params' do
      let(:params) { {
        :install_path => '/var/sensu/plugins',
      } }

      it { should contain_file('/var/sensu/plugins/plug1').with(
        'source'      => 'puppet:///data/plug1'
      ) }
    end
  end #file

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
        'force'   => false
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
  end #package

  context 'default' do
    let(:params) { { :type => 'unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end #default

end
