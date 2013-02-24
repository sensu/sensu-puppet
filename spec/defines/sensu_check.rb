require 'spec_helper'

describe 'sensu::check', :type => :define do
  let(:title) { 'mycheck' }

  context 'defaults' do
    let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

    it { should contain_sensu_check_config('mycheck').with(
      'realname'    => 'mycheck',
      'command'     => '/etc/sensu/somecommand.rb',
      'handlers'    => [],
      'interval'    => '60',
      'subscribers' => []
    ) }
  end

  context 'setting params' do
    let(:params) { {
      :command      => '/etc/sensu/command2.rb',
      :handlers     => ['/handler1', '/handler2'],
      :interval     => '10',
      :subscribers  => ['all']
    } }

    it { should contain_sensu_check_config('mycheck').with(
      'realname'    => 'mycheck',
      'command'     => '/etc/sensu/command2.rb',
      'handlers'    => ['/handler1', '/handler2'],
      'interval'    => '10',
      'subscribers' => ['all']
    ) }
  end

end
