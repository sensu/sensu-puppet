require 'spec_helper'

describe 'sensu::contact', :type => :define do
  let(:facts) { { 'Class[sensu::service::server]' => true } }
  let(:params) { { } }

  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    include ::sensu
    ENDofPUPPETcode
  end
  let(:title) { 'support' }

  context 'default (ensure => present)' do
    it 'manages the config file ownership and permissions' do
      expect(subject).to contain_file('/etc/sensu/conf.d/contacts/support.json').with(
        ensure: 'file',
        owner: 'sensu',
        group: 'sensu',
        mode: '0440',
      )
    end
    it 'defaults to an empty config hash' do
      expect(subject).to contain_sensu_contact('support').with(ensure: 'present', config: {})
    end
  end

  describe 'ensure => absent' do
    let(:params) { { ensure: 'absent' } }
    it { is_expected.to contain_sensu_contact(title).with_ensure('absent') }
    it do
      is_expected.to contain_file("/etc/sensu/conf.d/contacts/#{title}.json").
        with_ensure('absent')
    end
  end

  describe 'config param' do
    let(:params) { { config: { 'email' => { 'to' => 'support@example.com' } } } }

    it 'passes the config hash to sensu_contact' do
      is_expected.to contain_sensu_contact(title).with_config(params[:config])
    end
  end

  describe 'base_path param' do
    context 'when specified' do
      let(:params) { { base_path: '/tmp/foo' } }

      it 'passes the base_path string to sensu_contact' do
        is_expected.to contain_sensu_contact(title).with_base_path('/tmp/foo')
      end
    end
    context 'when not specified' do
      it 'defers to sensu_contact by passing undef' do
        is_expected.to contain_sensu_contact(title).without_base_path
      end
    end
  end
end
