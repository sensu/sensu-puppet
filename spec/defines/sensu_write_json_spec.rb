require 'spec_helper'

CFG_PATH = '/etc/sensu/conf.d/custom.json'
CUSTOM_CFG = {"custom" => "data"}
CUSTOM_CFG_PRETTY = <<-END.gsub(/^\s+\|/, '')
	|{
  |    "custom": "data"
  |}
END

describe 'sensu::write_json', :type => :define do
  let(:facts) { { :osfamily => 'RedHat' } }

  context 'with various params' do
    let(:title) { CFG_PATH }

    context 'defaults' do
      let(:params) { {
        :owner => 'sensu',
        :group => 'sensu',
        :content => CUSTOM_CFG,
      } }

      it { should contain_sensu__write_json(CFG_PATH).with(
        :ensure => 'present',
        :mode => '0755',
        :owner => 'sensu',
        :group => 'sensu',
        :pretty => true,
        :content => CUSTOM_CFG,
      ) }

      it { should contain_file(CFG_PATH).with(
        :ensure => 'present',
        :mode => '0755',
        :owner => 'sensu',
        :group => 'sensu',
        :content => CUSTOM_CFG_PRETTY,
        :notify => nil,
        :subscribe => nil,
      ) }

    end

    context 'setting absent' do
      let(:params) { {
        :ensure => 'absent',
        :mode => '0700',
        :owner => 'root',
        :group => 'root',
      } }

      it { should contain_file(CFG_PATH).with(
        :ensure => 'absent',
        :mode => '0700',
        :notify => nil,
        :subscribe => nil,
      ) }
    end

    context 'disable pretty print' do
      let(:params) { {
        :owner => 'root',
        :group => 'root',
        :pretty => false,
        :content => CUSTOM_CFG,
      } }

      it { should contain_file(CFG_PATH).with(
        :ensure => 'present',
        :mode => '0755',
        :owner => 'root',
        :group => 'root',
        :content => "{\"custom\":\"data\"}",
        :notify => nil,
        :subscribe => nil,
      ) }
    end
  end

  context 'invalid file name' do
    let(:title) { 'this not valid' }
    context 'defaults' do
      let(:params) { {
        :owner => 'sensu',
        :group => 'sensu',
      } }

      it { is_expected.to compile.and_raise_error(/a match for/) }
    end
  end

  context 'cannot use a windows file name on unix' do
    let(:title) { 'c:\nope.json' }
    context 'defaults' do
      let(:params) { {
        :owner => 'sensu',
        :group => 'sensu',
      } }

      it { is_expected.to compile.and_raise_error(/a match for/) }
    end
  end

  context 'cannot use a unix file name on windows' do
    let(:title) { CFG_PATH }
    context 'defaults' do
      let(:facts) { { :kernel => 'windows' } }

      let(:params) { {
        :owner => 'sensu',
        :group => 'sensu',
      } }

      it { is_expected.to compile.and_raise_error(/a match for/) }
    end
  end

end
