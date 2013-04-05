require 'spec_helper'

describe 'sensu::repo::apt', :type => :class do

  define 'with puppet-apt installed' do
    context 'ensure: present' do
      let(:facts) { { :apt::source => true, :apt::key => true } }
      let(:params) { { :ensure => 'present', :repo => 'main' } }
      it { should contain_apt__source('sensu').with(
        'ensure'      => 'present',
        'location'    => 'http://repos.sensuapp.org/apt',
        'release'     => 'sensu',
        'repos'       => 'main',
        'include_src' => false,
        'before'      => 'Package[sensu]'
      ) }

      it { should contain_apt__key('sensu').with(
        'key'         => '7580C77F',
        'key_source'  => 'http://repos.sensuapp.org/apt/pubkey.gpg'
      ) }
    end

    context 'ensure: absent' do
      let(:facts) { { :apt::source => true, :apt::key => true } }
      let(:params) { { :ensure => 'absent', :repo => 'main' } }
      it { should contain_apt__source('sensu').with(
        'ensure'      => 'absent',
        'location'    => 'http://repos.sensuapp.org/apt',
        'release'     => 'sensu',
        'repos'       => 'main',
        'include_src' => false,
        'before'      => 'Package[sensu]'
      ) }

      it { should contain_apt__key('sensu').with(
        'key'         => '7580C77F',
        'key_source'  => 'http://repos.sensuapp.org/apt/pubkey.gpg'
      ) }
    end
  end

  context 'without puppet-apt installed' do
    let(:params) { { :ensure => 'present', :repo => 'main' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

end


#  if defined(apt::source) and defined(apt::key) {
