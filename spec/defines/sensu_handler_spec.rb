require 'spec_helper'

describe 'sensu::handler', :type => :define do
  let(:facts) { { :osfamily => 'RedHat' } }
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
      :type        => 'pipe',
      :command     => '/etc/sensu/handlers/mycommand.rb',
      :filters     => [],
      :severities  => ['ok', 'warning', 'critical', 'unknown']
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
    it { should contain_file('/etc/mycommand.rb') }
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

    it { should contain_sensu_handler('myhandler').with_subdue( {'begin' => '09PM CEST', 'end'   => '10PM CEST'} ) }
  end

end
