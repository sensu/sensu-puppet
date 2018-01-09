require 'spec_helper'

CFG_PATH = '/etc/sensu/conf.d/custom.json'
CUSTOM_CFG = {"custom" => "data"}
CUSTOM_CFG_PRETTY = <<-END.gsub(/^\s+\|/, '')
  |{
  |    "custom": "data"
  |}
END

describe 'sensu::write_json', :type => :define do
  let(:facts) do
    {
      :osfamily => 'RedHat',
      :kernel   => 'Linux',
    }
  end

  context 'with various params' do
    let(:title) { CFG_PATH }

    context 'defaults' do
      let(:params) { {
        :content => CUSTOM_CFG,
      } }

      it { should contain_sensu__write_json(CFG_PATH).with(
        :ensure => 'present',
        :mode => '0775',
        :owner => 'sensu',
        :group => 'sensu',
        :pretty => true,
        :content => CUSTOM_CFG,
      ) }

      it { should contain_file(CFG_PATH).with(
        :ensure => 'present',
        :mode => '0775',
        :owner => 'sensu',
        :group => 'sensu',
        :content => CUSTOM_CFG_PRETTY,
        :notify => [],
        :subscribe => nil,
      ) }
    end

    context 'setting ensure to absent' do
      let(:params) { {
        :ensure => 'absent',
      } }

      it { should contain_file(CFG_PATH).with(
        :ensure => 'absent',
        :owner => 'sensu',
        :group => 'sensu',
        :mode => '0775',
        :notify => [],
        :subscribe => nil,
      ) }
    end

    context 'setting owner as non-default value' do
      let(:params) { {
        :owner => 'custom',
      } }

      it { should contain_file(CFG_PATH).with(
        :owner => 'custom',
      ) }
    end

    context 'setting group as non-default value' do
      let(:params) { {
        :group => 'custom',
      } }

      it { should contain_file(CFG_PATH).with(
        :group => 'custom',
      ) }
    end

    context 'setting mode as non-default value' do
      let(:params) { {
        :mode => '0777',
      } }

      it { should contain_file(CFG_PATH).with(
        :mode => '0777',
      ) }
    end

    context 'disable pretty print' do
      let(:params) { {
        :pretty => false,
        :content => CUSTOM_CFG,
      } }

      it { should contain_file(CFG_PATH).with(
        :ensure => 'present',
        :mode => '0775',
        :owner => 'sensu',
        :group => 'sensu',
        :content => "{\"custom\":\"data\"}",
        :notify => [],
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
