require 'spec_helper'

describe 'sensu::handler', :type => :define do
  let(:title) { 'myhandler' }

  context 'default (present)' do

    let(:params) { { :type => 'pipe', :command => '/etc/sensu/mycommand.rb' } }
    it { should contain_sensu_handler_config('myhandler').with(
      'type'    => 'pipe',
      'command' => '/etc/sensu/mycommand.rb',
      'ensure'  => 'present'
    ) }

  end

  context 'absent' do

    let(:params) { { :type => 'pipe', :command => '/etc/sensu/mycommand.rb', :ensure => 'absent' } }
    it { should contain_sensu_handler_config('myhandler').with_ensure('absent') }

  end

end
