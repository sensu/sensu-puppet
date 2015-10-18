require 'spec_helper'

describe 'sensu::mutator', :type => :define do
  let(:title) { 'mymutator' }

  context 'default (present)' do

    let(:params) { {
      :command  => '/etc/sensu/mutators/mycommand.rb',
      :source   => 'puppet:///somewhere/mycommand.rb'
    } }
    it { should contain_file('/etc/sensu/mutators/mycommand.rb').with_source('puppet:///somewhere/mycommand.rb')}
    it { should contain_sensu_mutator('mymutator').with(
      :ensure      => 'present',
      :command     => '/etc/sensu/mutators/mycommand.rb'
    ) }
    it do
      should contain_file("/etc/sensu/conf.d/mutators/#{title}.json").with(
        :ensure => 'file',
        :owner  => 'sensu',
        :group  => 'sensu',
        :mode   => '0440'
      ).that_comes_before("Sensu_Mutator[#{title}]")
    end
  end

  context 'absent' do
    let(:facts) { { 'Class[sensu::service::server]' => true } }
    let(:params) { {
      :ensure  => 'absent',
      :command => '/etc/sensu/mutators/mycommand.rb',
      :source  => 'puppet:///somewhere/mycommand.rb'
    } }
    it { should contain_sensu_mutator('mymutator').with_ensure('absent') }
    it do
      should contain_file("/etc/sensu/conf.d/mutators/#{title}.json").
        with_ensure('absent').
        that_comes_before("Sensu_Mutator[#{title}]")
    end
  end

  context 'install path' do
    let(:params) { {
      :command      => '/etc/mycommand.rb',
      :install_path => '/etc',
      :source       => 'puppet:///mycommand.rb'
    } }
    it { should contain_file('/etc/mycommand.rb') }
    it { should contain_sensu_mutator('mymutator').with_command('/etc/mycommand.rb') }
  end

  context 'command' do
    let(:params) { {
      :command => '/somewhere/file/script.sh'
    } }

    it { should contain_sensu_mutator('mymutator').with_command('/somewhere/file/script.sh') }
  end

  context 'source' do
    let(:params) { {
      :source  => 'puppet:///sensu/mutator/script.sh',
      :command => '/etc/sensu/mutators/script.sh'
    } }

    it { should contain_file('/etc/sensu/mutators/script.sh').with_ensure('file')}
    it { should contain_sensu_mutator('mymutator').with_command('/etc/sensu/mutators/script.sh') }
  end

  context 'source and command' do
    let(:params) { {
      :command => '/etc/sensu/mutators/script.sh',
      :source  => 'puppet:///sensu/mutator/script.sh'
    } }

    it { should contain_file('/etc/sensu/mutators/script.sh').with_ensure('file') }
    it { should contain_sensu_mutator('mymutator').with_command('/etc/sensu/mutators/script.sh') }
  end

end
