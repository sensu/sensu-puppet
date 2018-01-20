require 'spec_helper'

describe 'sensu::handler', :type => :define do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    include ::sensu
    ENDofPUPPETcode
  end
  let(:title) { 'myhandler' }

  context 'default (present)' do

    let(:params) { {
      :type     => 'pipe',
      :command  => '/etc/sensu/handlers/mycommand.rb',
      :source   => 'puppet:///somewhere/mycommand.rb'
    } }
    it { should contain_file('/etc/sensu/handlers/mycommand.rb').with_source('puppet:///somewhere/mycommand.rb')}
    it { should contain_sensu_handler('myhandler').with(
      :ensure      => 'present',
      :base_path   => '/etc/sensu/conf.d/handlers',
      :type        => 'pipe',
      :command     => '/etc/sensu/handlers/mycommand.rb',
      :filters     => [],
      :severities  => ['ok', 'warning', 'critical', 'unknown'],
      :require     => 'File[/etc/sensu/conf.d/handlers]'
    ) }
    it do
      should contain_file("/etc/sensu/conf.d/handlers/#{title}.json").with(
        :ensure => 'file',
        :owner  => 'sensu',
        :group  => 'sensu',
        :mode   => '0440'
      )
    end
  end

  context 'absent' do
    let(:facts) { { 'Class[sensu::service::server]' => true } }
    let(:params) { {
      :type => 'pipe',
      :ensure => 'absent',
      :source => 'puppet:///somewhere/mycommand.rb'
    } }
    it { should contain_sensu_handler('myhandler').with_ensure('absent') }
    it do
      should contain_file("/etc/sensu/conf.d/handlers/#{title}.json").
        with_ensure('absent')
    end
  end

  context 'install path' do
    let(:params) { {
      :install_path => '/etc',
      :source       => 'puppet:///mycommand.rb'
    } }
    it { should contain_file('/etc/mycommand.rb').with({
      :ensure => 'file',
      :owner  => 'sensu',
      :group  => 'sensu',
      :mode   => '0555',
      :source => 'puppet:///mycommand.rb'
    }) }
  end

  context 'command' do
    let(:params) { {
      :command => '/somewhere/file/script.sh'
    } }

    it { should contain_sensu_handler('myhandler').with_command('/somewhere/file/script.sh') }
  end

  context 'source' do
    let(:params) { { :source => 'puppet:///sensu/handler/script.sh' } }

    it { should contain_file('/etc/sensu/handlers/script.sh').with_ensure('file')}
    it { should contain_sensu_handler('myhandler').with_command('/etc/sensu/handlers/script.sh') }
  end

  context 'source and command' do
    let(:params) { {
      :command => 'script.sh',
      :source  => 'puppet:///sensu/handler/script.sh'
    } }

    it { should contain_file('/etc/sensu/handlers/script.sh').with_ensure('file') }
    it { should contain_sensu_handler('myhandler').with_command('script.sh') }
  end

  context 'handlers' do
    let(:params) { { :type => 'set', :handlers => ['mailer', 'hipchat'] } }
    it { should contain_sensu_handler('myhandler').with(
      :ensure      => 'present',
      :type        => 'set',
      :handlers    => ['mailer', 'hipchat'],
      :severities  => ['ok', 'warning', 'critical', 'unknown']
    ) }
  end

  context 'exchange' do
    let(:params) { { :type => 'amqp', :exchange => { 'type' => 'topic' } } }

    it { should contain_sensu_handler('myhandler').with_exchange({'type' => 'topic'}) }
  end

  context 'tcp' do
    let(:params) {
      {
        :type => 'tcp',
        :socket => {
          'host' => '192.168.23.23',
          'port' => '2003'
        }
      }
    }
    it { should contain_sensu_handler('myhandler').with_socket({'host' => '192.168.23.23', 'port' => '2003'}) }
  end

  context 'transport' do
    let(:params) {
      {
        :type       => 'transport',
        :pipe       => {
          'type'    => 'topic',
          'name'    => 'events',
          'options' => {
            'passive' => 'true',
            'durable' => 'true'
          }
        }
      }
    }
    it { should contain_sensu_handler('myhandler').with_pipe({
      'type'    => 'topic',
      'name'    => 'events',
      'options' => {
        'passive' => 'true',
        'durable' => 'true'
      }
    }) }
  end

  context 'mutator' do
    let(:params) { { :mutator => 'only_check_output' } }

    it { should contain_sensu_handler('myhandler').with_mutator('only_check_output') }
  end

  context 'config' do
    let(:params) { { :command => 'mycommand.rb', :config => {'param' => 'value'} } }

    it { should contain_sensu_handler('myhandler').with_config( {'param' => 'value' } ) }
  end

  context 'subdue' do
    let(:params) {
      {
        :command => 'mycommand.rb',
        :type    => 'pipe',
        :subdue  => {
          'begin' => '09PM CEST',
          'end'   => '10PM CEST'
        }
      }
    }

    it { should raise_error(Puppet::Error, /Subdue at handler is deprecated since sensu 0.26/) }
  end

  context 'timeout' do
    let(:params) {
      {
          :command => 'mycommand.rb',
          :type    => 'pipe',
          :timeout => 10,
      }
    }

    it { should contain_sensu_handler('myhandler').with_timeout( 10 ) }
  end

  context 'handle_flapping' do
    let(:params) { { :command => 'mycommand.rb', :type => 'pipe', :handle_flapping => true } }
    it { should contain_sensu_handler('myhandler').with_handle_flapping( true ) }
  end

  context 'handle_silenced' do
    let(:params) { { :command => 'mycommand.rb', :type => 'pipe', :handle_silenced => true } }
    it { should contain_sensu_handler('myhandler').with_handle_silenced( true ) }
  end

  context 'handle_silenced set to false' do
    let(:params) { { :command => 'mycommand.rb', :type => 'pipe', :handle_silenced => false } }
    it { should contain_sensu_handler('myhandler').with_handle_silenced( false ) }
  end

  context 'handle_silenced set to default' do
    let(:params) { { :command => 'mycommand.rb', :type => 'pipe' } }
    it { should contain_sensu_handler('myhandler').with_handle_silenced( false ) }
  end

  context 'windows' do
    let(:facts) do
      {
        :osfamily => 'windows',
        :kernel   => 'windows',
        :os => {
          :release => {
            :major => '2012r2'
          }
        }
      }
    end
    context 'default (present)' do

      let(:params) { {
        :type     => 'pipe',
        :command  => 'C:/opt/sensu/handlers/mycommand.rb',
        :source   => 'puppet:///somewhere/mycommand.rb'
      } }
      it { should contain_file('C:/opt/sensu/handlers/mycommand.rb').with({
        :ensure => 'file',
        :owner  => 'NT Authority\SYSTEM',
        :group  => 'Administrators',
        :mode   => nil,
        :source => 'puppet:///somewhere/mycommand.rb'
      }) }
      it { should contain_sensu_handler('myhandler').with(
        :ensure      => 'present',
        :base_path   => 'C:/opt/sensu/conf.d/handlers',
        :type        => 'pipe',
        :command     => 'C:/opt/sensu/handlers/mycommand.rb',
        :filters     => [],
        :severities  => ['ok', 'warning', 'critical', 'unknown'],
        :require     => 'File[C:/opt/sensu/conf.d/handlers]'
      ) }
      it do
        should contain_file("C:/opt/sensu/conf.d/handlers/#{title}.json").with(
          :ensure => 'file',
          :owner  => 'NT Authority\SYSTEM',
          :group  => 'Administrators',
          :mode   => nil
        )
      end
    end
  end
end
