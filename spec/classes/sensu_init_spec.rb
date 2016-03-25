require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) { { :osfamily => 'RedHat' } }

  it 'should compile' do should create_class('sensu') end
  it { should contain_user('sensu') }

  context 'with manage_user => false' do
    let(:params) { {:manage_user => false} }
    it { should_not contain_user('sensu') }
  end

  context 'fail if dashboard parameter present' do
    let(:params) { {:dashboard => true} }
    it { expect { should create_class('sensu') }.to raise_error(/Sensu-dashboard is deprecated, use a dashboard module/) }
  end

  context 'fail if purge_config parameter present' do
    let(:params) { { :purge_config => true } }

    it { expect { should create_class('sensu') }.to raise_error(/purge_config is deprecated, set the purge parameter to a hash containing `config => true` instead/) }
  end

  context 'fail if purge_plugins_dir parameter present' do
    let(:params) { { :purge_plugins_dir => true } }

    it { expect { should create_class('sensu') }.to raise_error(/purge_plugins_dir is deprecated, set the purge parameter to a hash containing `plugins => true` instead/) }
  end

  context 'fail if :enterprise => true AND :server => true' do
    let(:params) { { :enterprise => true, :server => true } }
    it { expect { should create_class('sensu') }.to raise_error(Puppet::Error, /sensu-server/) }
  end

  context 'fail if :enterprise => true AND :api => true' do
    let(:params) { { :enterprise => true, :api => true } }
    it { expect { should create_class('sensu') }.to raise_error(Puppet::Error, /sensu-api/) }
  end

  context 'with filters attributes' do
    let(:params) { {
      :filters => {
        'recurrences-30' => {
          'attributes' => {
            'occurrences' => "eval: value == 1 || value % 30 == 0"
          }
        },
        'production' => {
          'attributes' => {
            'client' => {
              'environment' => 'production'
            }
          },
          'negate' => true
        }
      },
      :filter_defaults => {
        'negate' => false
      }
    } }

    it { should contain_sensu_filter('recurrences-30').with(
      :attributes => {
        'occurrences' => "eval: value == 1 || value % 30 == 0"
      },
      :negate => false
    ) }
    it { should contain_file('/etc/sensu/conf.d/filters/recurrences-30.json') }

    it { should contain_sensu_filter('production').with(
      :attributes => {
        'client' => {
          'environment' => 'production'
        }
      },
      :negate => true
    ) }
    it { should contain_file('/etc/sensu/conf.d/filters/production.json') }
  end

  context 'with checks attributes' do
    let(:params) { {
      :checks => {
        'some-check' => {
          'type'     => 'pipe',
          'command'  => '/usr/local/bin/some-check',
          'handlers' => ['email']
        },
        'check-cpu' => {
          'type'        => 'pipe',
          'command'     => '/usr/local/bin/check-cpu.rb',
          'occurrences' => '5',
          'handlers'    => 'irc'
        }
      },
      :check_defaults => {
        'occurrences' => '1'
      }
    } }

    it { should contain_sensu_check('some-check').with(
      :type        => 'pipe',
      :command     => '/usr/local/bin/some-check',
      :occurrences => '1',
      :handlers    => ['email']
    ) }
    it { should contain_file('/etc/sensu/conf.d/checks/some-check.json') }

    it { should contain_sensu_check('check-cpu').with(
      :type        => 'pipe',
      :command     => '/usr/local/bin/check-cpu.rb',
      :occurrences => '5',
      :handlers    => 'irc'
    ) }
    it { should contain_file('/etc/sensu/conf.d/checks/check-cpu.json') }
  end

  context 'with handlers attributes' do
    let(:params) { {
        :handlers => {
          'hipchat_main_room' => {
            'type'   => 'pipe',
            'source' => 'puppet:///modules/sensu_module/community-plugins/handlers/notification/hipchat.rb',
            'config' => {
              'apikey' => 'my_long_api_key',
              'room'   => 'Big Alerts'
            }
          },
          'hipchat_other_room' => {
            'type'   => 'pipe',
            'source' => 'puppet:///modules/sensu_module/community-plugins/handlers/notification/hipchat.rb',
            'config' => {
              'apikey' => 'my_other_long_api_key',
              'room'   => 'Small Alerts'
            }
          }
        }
    } }

    it { should contain_file('/etc/sensu/handlers/hipchat.rb').with(
        :ensure => 'file',
        :owner  => 'sensu',
        :group  => 'sensu',
        :mode   => '0555',
        :source => "puppet:///modules/sensu_module/community-plugins/handlers/notification/hipchat.rb"
    )}
  end
end
