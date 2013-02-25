require 'spec_helper'

describe 'sensu::repo::yum', :type => :class do

  context 'ensure: present' do
    let(:params) { { :ensure => 'present' } }
    it { should contain_yumrepo('sensu').with(
      'enabled'   => 1,
      'baseurl'   => 'http://repos.sensuapp.org/yum/el/$releasever/$basearch/',
      'gpgcheck'  => 0,
      'before'    => 'Package[sensu]'
    ) }
  end

  context 'ensure: absent' do
    let(:params) { { :ensure => 'absent' } }
    it { should contain_yumrepo('sensu').with(
      'enabled' => 'absent',
      'before'  => 'Package[sensu]'
    ) }
  end

  context 'ensure: foo' do
    let(:params) { { :ensure => 'foo' } }
    it { should contain_yumrepo('sensu').with(
      'enabled' => 'absent',
      'before'  => 'Package[sensu]'
    ) }
  end
end