require 'spec_helper'

describe 'sensu::check', :type => :define do
  context 'without whitespace in name' do
    let(:title) { 'mycheck' }

    context 'defaults' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

      it { should contain_sensu_check('mycheck').with(
        'command'     => '/etc/sensu/somecommand.rb',
        'handlers'    => [],
        'interval'    => '60',
        'subscribers' => []
      ) }

    end

    context 'setting params' do
      let(:params) { {
        :command              => '/etc/sensu/command2.rb',
        :handlers             => ['/handler1', '/handler2'],
        :interval             => '10',
        :subscribers          => ['all'],
        :custom               => { 'a' => 'b', 'array' => [ 'c', 'd']},
        :type                 => 'metric',
        :standalone           => true,
        :low_flap_threshold   => 10,
        :high_flap_threshold  => 15
      } }

      it { should contain_sensu_check('mycheck').with(
        'command'             => '/etc/sensu/command2.rb',
        'handlers'            => ['/handler1', '/handler2'],
        'interval'            => '10',
        'subscribers'         => ['all'],
        'custom'              => { 'a' => 'b', 'array' => [ 'c', 'd']},
        'type'                => 'metric',
        'standalone'          => true,
        'low_flap_threshold'  => '10',
        'high_flap_threshold' => '15'
      ) }
    end

    context 'ensure absent' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb', :ensure => 'absent' } }

      it { should contain_sensu_check('mycheck').with_ensure('absent') }
    end
  end

  context 'with whitespace in name' do
    let(:title) { 'mycheck foobar' }
    context 'defaults' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

      it { should contain_sensu_check('mycheck_foobar').with(
        'command'     => '/etc/sensu/somecommand.rb',
        'handlers'    => [],
        'interval'    => '60',
        'subscribers' => []
      ) }

      it { should contain_file('/etc/sensu/conf.d/checks/mycheck_foobar.json') }

    end

  end

end
