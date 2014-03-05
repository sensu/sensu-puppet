require 'spec_helper'

describe 'sensu', :type => :class do

  it 'should compile' do should create_class('sensu') end
  it { should contain_user('sensu') }

  context 'with manage_user => false' do
    let(:params) { {:manage_user => false} }
    it { should_not contain_user('sensu') }
  end

end



