require 'spec_helper'

describe 'sensu::filter', :type => :define do
  let(:title) { 'myfilter' }

  context 'negate' do
    let(:params) { {:negate => false } }
    it { should contain_file('/etc/sensu/conf.d/filters/myfilter.json').with(:ensure => 'present') }
    it { should contain_sensu_filter('myfilter').with( :negate => false ) }
  end

  context 'attributes' do
    let(:params) { {
      :attributes => { 'a' => 'b', 'c' => 'd' }
    } }
    it { should contain_file('/etc/sensu/conf.d/filters/myfilter.json').with(:ensure => 'present') }
    it { should contain_sensu_filter('myfilter').with(:attributes => { 'a' => 'b', 'c' => 'd' } ) }
  end

  context 'absent' do
    let(:params) { {
      :ensure => 'absent'
    } }
    it { should contain_file('/etc/sensu/conf.d/filters/myfilter.json').with(:ensure => 'absent') }
    it { should contain_sensu_filter('myfilter').with(:ensure => 'absent') }
  end

end
