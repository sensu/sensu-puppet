require 'spec_helper'

describe 'sensu' do
  let(:facts) do
    { 'operatingsystem' => 'RedHat', }
  end      
  let(:params) do
    { 'install_repo' => true, }
  end      
  context 'on RedHat derivatives' do
    it { should create_class('sensu::repo::yum') }
    it { should contain_yumrepo('sensu').with(
      :enabled  => '1',
      :baseurl  => 'https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch/',
      :gpgcheck => '0',
      :name     => 'sensu',
      :descr    => 'sensu',
      :before   => 'Package[sensu]',
    ) }
  end
    
  context 'on Amazon Linux' do
    let(:facts) do
      { 'operatingsystem' => 'Amazon', }
    end
    it { should create_class('sensu::repo::yum') }
    it { should contain_yumrepo('sensu').with(
      :enabled  => '1',
      :baseurl  => 'https://sensu.global.ssl.fastly.net/yum/6/$basearch/',
      :gpgcheck => '0',
      :name     => 'sensu',
      :descr    => 'sensu',
      :before   => 'Package[sensu]',
    ) }
  end

end
