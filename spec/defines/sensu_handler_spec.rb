require 'spec_helper'

describe 'sensu::handler', :type => :define do
  let(:title) { 'myhandler' }
  let(:params) { { :type => 'pipe', :command => '/etc/sensu/mycommand.rb' } }

  it { should contain_sensu_handler_config('myhandler').with(
    'type'    => 'pipe',
    'command' => '/etc/sensu/mycommand.rb',
    'before'  => 'Service[sensu-server]'
  ) }
end
