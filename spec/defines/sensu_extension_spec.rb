require 'spec_helper'

describe 'sensu::extension', :type => :define do
  let(:title) { 'myextension' }

  context 'default (present)' do
    let(:params) { {
      :source => 'puppet:///somewhere/mycommand.rb'
    } }
    it { should contain_file('/etc/sensu/extensions/mycommand.rb').with_source('puppet:///somewhere/mycommand.rb')}
    it { should contain_file('/etc/sensu/conf.d/extensions/myextension.json') }
    it { should contain_sensu_extension('myextension').with(
      :ensure => 'present',
      :config => {}
    ) }
  end

  context 'absent' do
    let(:facts) { { 'Class[sensu::service::server]' => true } }
    let(:params) { {
      :ensure => 'absent',
      :source => 'puppet:///somewhere/mycommand.rb'
    } }
    it { should contain_sensu_extension('myextension').with_ensure('absent') }
    it { should contain_file('/etc/sensu/conf.d/extensions/myextension.json').with_ensure('absent') }
  end

  context 'install path' do
    let(:params) { {
      :install_path => '/etc',
      :source       => 'puppet:///mycommand.rb'
    } }
    it { should contain_file('/etc/mycommand.rb') }
  end

  context 'source' do
    let(:params) { {
      :source => 'puppet:///sensu/extension/script.rb'
    } }
    it { should contain_file('/etc/sensu/extensions/script.rb').with(
      :ensure => 'file',
      :source => 'puppet:///sensu/extension/script.rb'
    ) }
  end

  context 'source and config' do
    let(:params) { {
      :source => 'puppet:///sensu/extension/script.rb',
      :config => {'param' => 'value'}
    } }
    it { should contain_file('/etc/sensu/extensions/script.rb').with(
      :ensure => 'file',
      :source => 'puppet:///sensu/extension/script.rb'
    ) }
    it { should contain_sensu_extension('myextension').with_config( {'param' => 'value'} ) }
  end

end
