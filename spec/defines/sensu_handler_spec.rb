require 'spec_helper'

describe 'sensu::handler', :type => :define do
  let(:title) { 'myhandler' }

  context 'default (present)' do

    let(:params) { { :type => 'pipe', :source => 'puppet:///somewhere/mycommand.rb' } }
    it { should contain_file('/etc/sensu/handlers/mycommand.rb').with_source('puppet:///somewhere/mycommand.rb')}
    it { should contain_sensu_handler('mycommand').with(
      'ensure'      => 'present',
      'type'        => 'pipe',
      'command'     => '/etc/sensu/handlers/mycommand.rb',
      'severities'  => ['ok', 'warning', 'critical', 'unknown']
    ) }
    it { should contain_sensu_handler_config('mycommand').with_ensure('absent') }
  end

  context 'absent' do
    let(:facts) { { 'Class[sensu::service::server]' => true } }
    let(:params) { { :type => 'pipe', :ensure => 'absent', :source => 'puppet:///somewhere/mycommand.rb' } }
    it { should contain_sensu_handler('mycommand').with_ensure('absent') }
    it { should contain_sensu_handler_config('mycommand').with_ensure('absent') }
  end

  context 'install path' do
    let(:params) { { :install_path => '/etc', :source => 'puppet:///mycommand.rb'} }
    it { should contain_file('/etc/mycommand.rb') }
  end

  context 'handlers' do
    let(:params) { { :handlers => ['mailer', 'hipchat'] } }
    it { should contain_sensu_handler('myhandler').with(
      'ensure'      => 'present',
      'type'        => 'pipe',
      'handlers'    => ['mailer', 'hipchat'],
      'severities'  => ['ok', 'warning', 'critical', 'unknown']
    ) }
  end

  context 'config' do
    let(:params) { { :config => { 'foo' => 'bar' }, :config_key => 'configkey' } }
    it { should contain_sensu_handler_config('configkey').with_config({'foo' => 'bar'} ) }
  end
end
