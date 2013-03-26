require 'spec_helper'

describe 'sensu::check', :type => :define do
  let(:title) { 'mycheck' }

  context 'defaults' do
    let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

    it { should contain_sensu_check('mycheck').with(
      'realname'    => 'mycheck',
      'command'     => '/etc/sensu/somecommand.rb',
      'handlers'    => [],
      'interval'    => '60',
      'subscribers' => []
    ) }

    it { should contain_sensu_check_config('mycheck').with_ensure('absent') }
  end

  context 'setting params' do
    let(:params) { {
      :command              => '/etc/sensu/command2.rb',
      :handlers             => ['/handler1', '/handler2'],
      :interval             => '10',
      :subscribers          => ['all'],
      :type                 => 'metric',
      :standalone           => true,
      :notification         => 'some text',
      :low_flap_threshold   => 10,
      :high_flap_threshold  => 15,
      :refresh              => 1800,
      :aggregate            => true,
      :config               => { 'foo' => 'bar' },
      :additional           => { 'additional' => 'exists' },
      :config_key           => 'mykey'
    } }

    it { should contain_sensu_check('mycheck').with(
      'realname'            => 'mycheck',
      'command'             => '/etc/sensu/command2.rb',
      'handlers'            => ['/handler1', '/handler2'],
      'interval'            => '10',
      'subscribers'         => ['all'],
      'type'                => 'metric',
      'standalone'          => true,
      'notification'        => 'some text',
      'low_flap_threshold'  => '10',
      'high_flap_threshold' => '15',
      'refresh'             => '1800',
      'aggregate'           => true
    ) }
    it { should contain_sensu_check_config('mykey').with_ensure('present')}
    it { should contain_sensu_check_config('mycheck').with_config({'additional' => 'exists'}) }
  end

  context 'ensure absent' do
    let(:params) { { :command => '/etc/sensu/somecommand.rb', :ensure => 'absent' } }

    it { should contain_sensu_check('mycheck').with_ensure('absent') }
    it { should contain_sensu_check_config('mycheck').with_ensure('absent') }
  end

  context 'purge_configs' do
    let(:params) { { :command => '/foo/bar', :purge_config => true, :config => { 'foo' => 'bar' } } }

    it { should contain_file('/etc/sensu/conf.d/check_mycheck.json').with_ensure('present') }
    it { should contain_file('/etc/sensu/conf.d/mycheck.json').with_ensure('present') }
  end

end
