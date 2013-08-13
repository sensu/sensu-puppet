require 'spec_helper'

describe 'sensu::repo', :type => :class do

  it { should create_class('sensu::repo') }

  ['Debian', 'Ubuntu' ].each do |os|
    describe "operatingsystem: #{os}" do
      let(:facts) { { :operatingsystem => os } }
      context 'no params' do
        it { should contain_class('sensu::repo::apt').with_ensure('present') }
      end

      ['present', 'absent'].each do |state|
        context "ensure: #{state}" do
          let(:params) { { :ensure => state } }
          it { should contain_class('sensu::repo::apt').with_ensure(state) }
        end
      end
    end
  end

  ['RedHat', 'CentOS' ].each do |os|
    describe "operatingsystem: #{os}" do
      let(:facts) { { :operatingsystem => os } }
      context 'no params' do
        it { should contain_class('sensu::repo::yum').with_ensure('present') }
      end

      ['present', 'absent'].each do |state|
        context "ensure: #{state}" do
          let(:params) { { :ensure => state } }
          it { should contain_class('sensu::repo::yum').with_ensure(state) }
        end
      end
    end
  end

  describe 'operatingsystem: Darwin' do
    let(:facts) { { :operatingsystem => 'Darwin' } }
    context 'no params' do
      it { expect { should raise_error(Puppet::Error) } }
    end

    ['present', 'absent'].each do |state|
      context "ensure => #{state}" do
        let(:params) { { :ensure => state } }
        it { expect { should raise_error(Puppet::Error) } }
      end
    end
  end
end

