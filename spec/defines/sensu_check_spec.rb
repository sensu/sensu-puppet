require 'spec_helper'

describe 'sensu::check', :type => :define do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    include ::sensu
    ENDofPUPPETcode
  end
  let(:facts) do
    {
      :osfamily => 'RedHat',
      :kernel   => 'Linux',
    }
  end

  let(:title) { 'mycheck' }
  let(:params_base) {{ command: '/etc/sensu/somecommand.rb' }}
  let(:params_override) {{}}
  let(:params) { params_base.merge(params_override) }
  # The default, basic output
  let :expected_content do
    JSON.parse(File.read(my_fixture('expected_check_mycheck.json')))
  end

  # The target file path
  let(:fpath) { "/etc/sensu/conf.d/checks/#{title}.json" }
  # (#783) Using sensu::write_json
  context 'with content' do
    let :expected_content do
      JSON.parse(File.read(my_fixture('expected_check_with_mailer_content.json')))
    end

    context 'containing sensu-plugins-mailer configuration' do
      let(:params_override) do
        {content: {'mailer' => {'mail_from' => 'sensu@example.com', 'mail_to' => 'alert@example.com'}}}
      end
      it { should contain_sensu__write_json(fpath).with(
        content: expected_content,
      ) }
    end

    context 'containing {"checks": {"mycheck": {"foo": "bar"}}}' do
      let :expected_content do
        JSON.parse(File.read(my_fixture('expected_check_mycheck.json')))
      end
      let(:params_override) do
        {content: {'checks' => {'mycheck' => {'foo' => 'bar'}}}}
      end
      # `custom` overrides `content` at the check scope level.
      it { should contain_sensu__write_json(fpath).with(
        content: expected_content,
      ) }
    end

    context 'containing {"checks": {"othercheck": {"foo": "bar"}}}' do
      let :expected_content do
        JSON.parse(File.read(my_fixture('expected_check_with_othercheck_content.json')))
      end
      let(:params_override) do
        {content: {'checks' => {'othercheck' => {'foo' => 'bar'}}}}
      end
      # `custom` overrides `content` at the check scope level.
      it { should contain_sensu__write_json(fpath).with(
        content: expected_content,
      ) }
    end
  end

  context 'without whitespace in name' do
    context 'defaults' do
      let :expected_content do
        {
          'checks' => {
            'mycheck' => {
              'command' => '/etc/sensu/somecommand.rb',
              'interval' => 60,
              'standalone' => true,
            },
          },
        }
      end

      it do
        rsrc_hsh = { content: expected_content }
        should contain_sensu__write_json(fpath).with(rsrc_hsh)
      end
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

      it do should contain_sensu__write_json(fpath).with(
        content: {
          'checks' => {
            'mycheck' => {
              'command'             => '/etc/sensu/command2.rb',
              'handlers'            => ['/handler1', '/handler2'],
              'interval'            => 10,
              'occurrences'         => 5,
              'refresh'             => 3600,
              'subscribers'         => ['all'],
              'remediation'         => { 'low_remediation' => { 'occurrences' => [1,2], 'severities' => [1], 'command' => "/bin/command", 'publish' => false, } },
              'type'                => 'metric',
              'standalone'          => true,
              'low_flap_threshold'  => 10,
              'high_flap_threshold' => 15,
              'timeout'             => 0.5,
              'aggregate'           => 'my_aggregate',
              'aggregates'          => ['aggregate_1', 'aggregate_2'],
              'handle'              => true,
              'publish'             => true,
              'ttl'                 => 30
            }
          }
        }
      )
      end
    end

    context 'ensure absent' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb', :ensure => 'absent' } }

      it { should contain_sensu__write_json(fpath).with_ensure('absent') }
    end

    context 'ensure absent with command undefined' do
      let(:params) { { :ensure => 'absent' } }
      it { should contain_sensu__write_json(fpath).with_ensure('absent') }
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

      let :expected_content do
        {"checks"=>{"mycheck"=>{"command"=>"/etc/sensu/command2.rb"}}}
      end

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end
  end

  context 'with whitespace in name' do
    let(:title) { 'mycheck foobar' }
    let(:fpath) { '/etc/sensu/conf.d/checks/mycheck_foobar.json' }

    context 'defaults' do
      it { should contain_sensu__write_json(fpath) }
      it { should contain_file(fpath) }
    end
  end

  context 'with parentheses in name' do
    let(:title) { 'mycheck (foo) bar' }
    let(:fpath) { '/etc/sensu/conf.d/checks/mycheck_foo_bar.json' }
    context 'defaults' do
      it { should contain_sensu__write_json(fpath) }
      it { should contain_file(fpath) }
    end
  end

  context 'notifications' do
    context 'no client, sever, or api' do
      let(:pre_condition) { 'class {"sensu": client => false, api => false, server => false}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => []) }
    end

    context 'only client' do
      let(:pre_condition) { 'class {"sensu": client => true, api => false, server => false}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => ['Service[sensu-client]'] ) }
    end

    context 'only server' do
      let(:pre_condition) { 'class {"sensu": client => false, api => false, server => true}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => ['Class[Sensu::Server::Service]'] ) }
    end

    context 'only api' do
      let(:pre_condition) { 'class {"sensu": client => false, api => true, server => false}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => ['Service[sensu-api]'] ) }
    end

    context 'client and api' do
      let(:pre_condition) { 'class {"sensu": client => true, api => true, server => false}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => ['Service[sensu-client]', 'Service[sensu-api]']) }
    end

    context 'client and server' do
      let(:pre_condition) { 'class {"sensu": client => true, api => false, server => true}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => ['Service[sensu-client]', 'Class[Sensu::Server::Service]']) }
    end

    context 'api and server' do
      let(:pre_condition) { 'class {"sensu": client => false, api => true, server => true}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => ['Class[Sensu::Server::Service]', 'Service[sensu-api]']) }
    end

    context 'client, api, and server' do
      let(:pre_condition) { 'class {"sensu": client => true, api => true, server => true}' }
      it { should contain_sensu__write_json(fpath).with(:notify_list => ['Service[sensu-client]', 'Class[Sensu::Server::Service]', 'Service[sensu-api]']) }
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

      let(:expected_content) do
        {"checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60, "subdue"=>{"days"=>{"monday"=>[{"begin"=>"12:00:00 AM PST", "end"=>"9:00:00 AM PST"}, {"begin"=>"5:00:00 PM PST", "end"=>"11:59:59 PM PST"}]}}}}}
      end

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
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

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end

    context '= undef' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
        }
      }

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end
  end

  describe 'param proxy_requests' do
    context 'valid proxy_requests hash' do
      let(:params_override) do
        { proxy_requests: { 'client_attributes' => { 'subscriptions' => 'eval: value.include?("http")' } } }
      end

      let :expected_content do
        {"checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60, "proxy_requests"=>{"client_attributes"=>{"subscriptions"=>"eval: value.include?(\"http\")"}}}}}
      end

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end

    context 'invalid proxy_requests hash' do
      let(:params_override) { {proxy_requests: {}} }
      it { should raise_error(Puppet::Error, /proxy_requests hash should have a proper format/) }
    end

    context '=> \'absent\'' do
      let(:params_override) { { proxy_requests: 'absent' } }

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end

    context '= undef' do
      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end
  end

  describe 'param hooks' do
    context 'valid hooks hash' do
      let(:params_override) do
        { hooks: { 'non-zero' => { 'command' => 'ps aux' , 'timeout' => '10' } } }
      end

      let :expected_content do
        {"checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60,                                                   "hooks"=>{"non-zero"=>{"command"=>"ps aux", "timeout"=>"10"}}}}}
      end

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end

    context 'invalid hooks hash' do
      let(:params_override) do
        { hooks: { 'a_value' => { 'command' => 'ps aux' , 'timeout' => '10' } } }
      end

      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /Illegal value for a_value hook. Valid values are: Integers from 1 to 255 and any of 'ok', 'warning', 'critical', 'unknown', 'non-zero'/)
      end
    end

    context '=> \'absent\'' do
      let(:params_override) { { hooks: 'absent' } }

      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end

    context '= undef' do
      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end
  end

  describe 'param cron' do
    context 'default behavior (not specified)' do
      let(:params_override) { {} }
      it { should contain_sensu__write_json(fpath).with_content(expected_content) }
    end

    context 'specifying cron' do
      let :expected_content do
        {"checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "cron"=>"*/5 * * * *"}}}
      end

      context 'without interval' do
        let(:params_override) { {cron: '*/5 * * * *'} }
        it { should contain_sensu__write_json(fpath).with_content(expected_content) }
      end

      context 'with interval' do
        let(:params_override) { {cron: '*/5 * * * *', interval: 99} }
        it { should contain_sensu__write_json(fpath).with_content(expected_content) }
      end
    end
  end

  describe 'relationships (#463)' do
    let(:expected) { { notify: ["Sensu::Check[#{title}]"] } }
    it { should contain_anchor('plugins_before_checks').with(expected)}
  end

  describe 'params conversions where arrays are expected (#803)' do
    context 'handlers is passed as String' do
      let(:params_override) { {handlers: 'default'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "handlers"=>["default"], "interval"=>60}}) }
    end
    context 'subscribers is passed as String' do
      let(:params_override) { {subscribers: 'default'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "subscribers"=>["default"], "interval"=>60}}) }
    end
    context 'aggregates is passed as String' do
      let(:params_override) { {aggregates: 'default'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "aggregates"=>["default"], "interval"=>60}}) }
    end
    context 'dependencies is passed as String' do
      let(:params_override) { {dependencies: 'default'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "dependencies"=>["default"], "interval"=>60}}) }
    end
    context 'contacts is passed as String' do
      let(:params_override) { {contacts: 'default'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "contacts"=>["default"], "interval"=>60}}) }
    end

    context 'handlers is passed as Array' do
      let(:params_override) { {handlers: ['default']} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "handlers"=>["default"], "interval"=>60}}) }
    end
    context 'subscribers is passed as Array' do
      let(:params_override) { {subscribers: ['default']} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "subscribers"=>["default"], "interval"=>60}}) }
    end
    context 'aggregates is passed as Array' do
      let(:params_override) { {aggregates: ['default']} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "aggregates"=>["default"], "interval"=>60}}) }
    end
    context 'dependencies is passed as Array' do
      let(:params_override) { {dependencies: ['default']} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "dependencies"=>["default"], "interval"=>60}}) }
    end
    context 'contacts is passed as Array' do
      let(:params_override) { {contacts: ['default']} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "contacts"=>["default"], "interval"=>60}}) }
    end

    context 'handlers is passed as absent' do
      let(:params_override) { {handlers: 'absent'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60}}) }
    end
    context 'subscribers is passed as absent' do
      let(:params_override) { {subscribers: 'absent'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60}}) }
    end
    context 'aggregates is passed as absent' do
      let(:params_override) { {aggregates: 'absent'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60}}) }
    end
    context 'dependencies is passed as absent' do
      let(:params_override) { {dependencies: 'absent'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60}}) }
    end
    context 'contacts is passed as absent' do
      let(:params_override) { {contacts: 'absent'} }
      it { should contain_sensu__write_json(fpath).with_content("checks"=>{"mycheck"=>{"standalone"=>true, "command"=>"/etc/sensu/somecommand.rb", "interval"=>60}}) }
    end
  end

end
