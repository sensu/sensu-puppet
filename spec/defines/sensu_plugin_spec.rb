require 'spec_helper'

describe 'sensu::plugin', :type => :define do
  let(:title) { 'puppet:///data/plug1' }

  context 'defaults' do

    it { should contain_file('/etc/sensu/plugins/plug1').with(
      'source'      => 'puppet:///data/plug1'
    ) }
  end

  context 'setting params' do
    let(:params) { {
      :install_path => '/var/sensu/plugins',
    } }

    it { should contain_file('/var/sensu/plugins/plug1').with(
      'source'      => 'puppet:///data/plug1'
    ) }
  end

end
