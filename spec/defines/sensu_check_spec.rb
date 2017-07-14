require 'spec_helper'

describe 'sensu::check', :type => :define do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    include ::sensu
    ENDofPUPPETcode
  end
  let(:facts) { { :osfamily => 'RedHat' } }

  let(:title) { 'mycheck' }
  let(:params_base) {{ command: '/etc/sensu/somecommand.rb' }}
  let(:params_override) {{}}
  let(:params) { params_base.merge(params_override) }

  context 'without whitespace in name' do
    context 'defaults' do
      it { should contain_sensu_check('mycheck').with(
        :command     => '/etc/sensu/somecommand.rb',
        :interval    => 60
      ) }
    end

    context 'setting params' do
      let(:params) { {
        :command             => '/etc/sensu/command2.rb',
        :handlers            => ['/handler1', '/handler2'],
        :interval            => 10,
        :occurrences         => 5,
        :refresh             => 3600,
        :subscribers         => ['all'],
        :custom              => { 'remediation' => { 'low_remediation' => { 'occurrences' => [1,2], 'severities' => [1], 'command' => "/bin/command", 'publish' => false, } } },
        :type                => 'metric',
        :standalone          => true,
        :low_flap_threshold  => 10,
        :high_flap_threshold => 15,
        :timeout             => 0.5,
        :aggregate           => 'my_aggregate',
        :aggregates          => ['aggregate_1', 'aggregate_2'],
        :handle              => true,
        :publish             => true,
        :ttl                 => 30
      } }

      it { should contain_sensu_check('mycheck').with(
        :command             => '/etc/sensu/command2.rb',
        :handlers            => ['/handler1', '/handler2'],
        :interval            => 10,
        :occurrences         => 5,
        :refresh             => 3600,
        :subscribers         => ['all'],
        :custom              => { 'remediation' => { 'low_remediation' => { 'occurrences' => [1,2], 'severities' => [1], 'command' => "/bin/command", 'publish' => false, } } },
        :type                => 'metric',
        :standalone          => true,
        :low_flap_threshold  => 10,
        :high_flap_threshold => 15,
        :timeout             => 0.5,
        :aggregate           => 'my_aggregate',
        :aggregates          => ['aggregate_1', 'aggregate_2'],
        :handle              => true,
        :publish             => true,
        :ttl                 => 30
      ) }
    end

    context 'ensure absent' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb', :ensure => 'absent' } }

      it { should contain_sensu_check('mycheck').with_ensure('absent') }
    end

    context 'ensure absent with command undefiend' do
      let(:params) { { :ensure => 'absent' } }
      it { should contain_sensu_check('mycheck').with_ensure('absent') }
    end

    context 'ensure present with command undefiend' do
      let(:params) { { :ensure => 'present' } }
      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /command must be given when ensure is present/)
      end
    end

    context 'setting params to absent' do
      let(:params) { {
        :command             => '/etc/sensu/command2.rb',
        :aggregate           => 'absent',
        :aggregates          => 'absent',
        :dependencies        => 'absent',
        :handle              => 'absent',
        :handlers            => 'absent',
        :high_flap_threshold => 'absent',
        :interval            => 'absent',
        :low_flap_threshold  => 'absent',
        :occurrences         => 'absent',
        :publish             => 'absent',
        :refresh             => 'absent',
        :source              => 'absent',
        :standalone          => 'absent',
        :subdue              => 'absent',
        :subscribers         => 'absent',
        :timeout             => 'absent',
        :ttl                 => 'absent',
        :type                => 'absent'
      } }

      it { should contain_sensu_check('mycheck').with(
        :command             => '/etc/sensu/command2.rb',
        :aggregate           => :absent,
        :aggregates          => :absent,
        :dependencies        => :absent,
        :handle              => :absent,
        :handlers            => :absent,
        :high_flap_threshold => :absent,
        :interval            => :absent,
        :low_flap_threshold  => :absent,
        :occurrences         => :absent,
        :publish             => :absent,
        :refresh             => :absent,
        :source              => :absent,
        :standalone          => :absent,
        :subdue              => :absent,
        :subscribers         => :absent,
        :timeout             => :absent,
        :ttl                 => :absent,
        :type                => :absent
      ) }
    end
  end

  context 'with whitespace in name' do
    let(:title) { 'mycheck foobar' }
    context 'defaults' do
      it { should contain_sensu_check('mycheck_foobar').with(
        :command     => '/etc/sensu/somecommand.rb',
        :interval    => '60'
      ) }

      it { should contain_file('/etc/sensu/conf.d/checks/mycheck_foobar.json') }
    end
  end

  context 'with brackets in name' do
    let(:title) { 'mycheck (foo) bar' }
    context 'defaults' do
      it { should contain_sensu_check('mycheck_foo_bar').with(
        'command'     => '/etc/sensu/somecommand.rb',
        'interval'    => '60'
      ) }

      it { should contain_file('/etc/sensu/conf.d/checks/mycheck_foo_bar.json') }
    end
  end

  context 'notifications' do
    context 'no client, sever, or api' do
      let(:pre_condition) { 'class {"sensu": client => false, api => false, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => []) }
    end

    context 'only client' do
      let(:pre_condition) { 'class {"sensu": client => true, api => false, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Client::Service]'] ) }
    end

    context 'only server' do
      let(:pre_condition) { 'class {"sensu": client => false, api => false, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Server::Service]'] ) }
    end

    context 'only api' do
      let(:pre_condition) { 'class {"sensu": client => false, api => true, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Api::Service]'] ) }
    end

    context 'client and api' do
      let(:pre_condition) { 'class {"sensu": client => true, api => true, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Client::Service]', 'Class[Sensu::Api::Service]']) }
    end

    context 'client and server' do
      let(:pre_condition) { 'class {"sensu": client => true, api => false, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Client::Service]', 'Class[Sensu::Server::Service]']) }
    end

    context 'api and server' do
      let(:pre_condition) { 'class {"sensu": client => false, api => true, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Server::Service]', 'Class[Sensu::Api::Service]']) }
    end

    context 'client, api, and server' do
      let(:pre_condition) { 'class {"sensu": client => true, api => true, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Client::Service]', 'Class[Sensu::Server::Service]', 'Class[Sensu::Api::Service]']) }
    end
  end

  context 'with subdue' do
    context 'valid subdue hash' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
          :subdue  => {
            'days' => {
              'monday' => [
                {
                  'begin' => '12:00:00 AM PST',
                  'end'   => '9:00:00 AM PST'
                },
                {
                  'begin' => '5:00:00 PM PST',
                  'end'   => '11:59:59 PM PST'
                }
              ]
            }
          }
        }
      }

      it { should contain_sensu_check('mycheck').with_subdue( {'days'=>{'monday'=>[{'begin'=>'12:00:00 AM PST', 'end'=>'9:00:00 AM PST'}, {'begin'=>'5:00:00 PM PST', 'end'=>'11:59:59 PM PST'}]}} ) }
    end

    context 'invalid subdue hash' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
          :subdue  => {
            'begin' => '5PM PST',
            'end'   => '9AM PST'
          }
        }
      }

      it { should raise_error(Puppet::Error, /subdue hash should have a proper format/) }
    end

    context '=> \'absent\'' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
          :subdue  => 'absent'
        }
      }

      it { should contain_sensu_check('mycheck').with_subdue(:absent) }
    end

    context '= undef' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
        }
      }

      it { should contain_sensu_check('mycheck').without_subdue }
    end
  end

  describe 'param proxy_requests' do
    context 'valid proxy_requests hash' do
      let(:params_override) do
        { proxy_requests: { 'client_attributes' => { 'subscriptions' => 'eval: value.include?("http")' } } }
      end

      it { should contain_sensu_check('mycheck').with_proxy_requests(params_override[:proxy_requests]) }
    end

    context 'invalid proxy_requests hash' do
      let(:params_override) { {proxy_requests: {}} }
      it { should raise_error(Puppet::Error, /proxy_requests hash should have a proper format/) }
    end

    context '=> \'absent\'' do
      let(:params_override) { { proxy_requests: 'absent' } }

      it { should contain_sensu_check('mycheck').with_proxy_requests(:absent) }
    end

    context '= undef' do
      it { should contain_sensu_check('mycheck').without_proxy_requests }
    end
  end

  describe 'param cron' do
    context 'default behavior (not specified)' do
      let(:params_override) { {} }
      it { is_expected.to contain_sensu_check('mycheck').with(cron: 'absent') }
      it { is_expected.to contain_sensu_check('mycheck').with(interval: 60) }
    end

    context 'without interval' do
      let(:params_override) { {cron: '*/5 * * * *'} }
      it { is_expected.to contain_sensu_check('mycheck').with(cron: params[:cron]) }
      it { is_expected.to contain_sensu_check('mycheck').with(interval: 'absent') }
    end

    context 'with interval' do
      let(:params_override) { {cron: '*/5 * * * *', interval: 99} }
      it { is_expected.to contain_sensu_check('mycheck').with(cron: params[:cron]) }
      it { is_expected.to contain_sensu_check('mycheck').with(interval: 'absent') }
    end
  end
end
