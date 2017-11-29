require 'spec_helper'

describe 'sensu', :type => :class do
  describe 'osfamily RedHat defaults' do
    let(:facts) { { :osfamily => 'RedHat' } }

    it 'should compile' do should create_class('sensu') end
    it { should contain_user('sensu') }
    it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_DIR=/var/log/sensu$}) }
    it { should contain_file('/etc/default/sensu').with_content(%r{^EMBEDDED_RUBY=true$}) }
    it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_LEVEL=info$}) }
    it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_DIR=/var/log/sensu$}) }
    it { should contain_file('/etc/default/sensu').without_content(%r{^RUBYOPT=.*$}) }
    it { should contain_file('/etc/default/sensu').without_content(%r{^GEM_PATH=.*$}) }
    it { should contain_file('/etc/default/sensu').without_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=.*$}) }
    it { should contain_file('/etc/default/sensu').with_content(%r{^SERVICE_MAX_WAIT="10"$}) }
    it { should contain_file('/etc/default/sensu').with_content(%r{^PATH=\$PATH$}) }
    it { should contain_file('/etc/default/sensu').without_content(%r{^CONFD_DIR=.*$}) }
    it { should contain_file('/etc/default/sensu').without_content(%r{^HEAP_SIZE=.*$}) }
    it { should_not contain_file('C:/opt/sensu/bin/sensu-client.xml') }

    # FIXME: The following resource checks are only testing $sensu_etc_dir specific values
    # resources from sensu::package
    it { should contain_file('/etc/sensu/conf.d') }
    it { should contain_file('/etc/sensu/conf.d/handlers') }
    it { should contain_file('/etc/sensu/conf.d/checks') }
    it { should contain_file('/etc/sensu/conf.d/filters') }
    it { should contain_file('/etc/sensu/conf.d/extensions') }
    it { should contain_file('/etc/sensu/conf.d/mutators') }
    it { should contain_file('/etc/sensu/conf.d/contacts') }
    it { should contain_file('/etc/sensu/handlers') }
    it { should contain_file('/etc/sensu/extensions') }
    it { should contain_file('/etc/sensu/extensions/handlers') }
    it { should contain_file('/etc/sensu/mutators') }
    it { should contain_file('/etc/sensu/plugins') }
    it { should contain_file('/etc/sensu/config.json') }
    # resources from sensu::rabbitmq::config
    it { should_not contain_file('/etc/sensu/ssl') }
    it { should_not contain_file('/etc/sensu/ssl/cert.pem').with_require('File[/etc/sensu/ssl]') }
    it { should_not contain_file('/etc/sensu/ssl/key.pem').with_require('File[/etc/sensu/ssl]') }
    it { should contain_file('/etc/sensu/conf.d/rabbitmq.json') }
    it { should contain_sensu_rabbitmq_config('testfqdn.example.com').with_base_path('/etc/sensu/conf.d') }
    # resources from sensu::redis::config
    it { should contain_file('/etc/sensu/conf.d/redis.json') }
    it { should contain_sensu_redis_config('testfqdn.example.com').with_base_path('/etc/sensu/conf.d') }
    # resources from sensu::api
    it { should contain_file('/etc/sensu/conf.d/api.json') }
    it { should contain_sensu_api_config('testfqdn.example.com').with_base_path('/etc/sensu/conf.d') }
    # resources from sensu::enterprise::dashboard
    it { should_not contain_file('/etc/sensu/dashboard.json') }
    # resources from sensu::subscription (positive tests are included in test for sensu::subscription itself)
    it { should_not contain_file('/etc/sensu/conf.d/subscriptiond.json') }
    it { should_not contain_sensu_client_subscription('mysubscription').with_base_path('/etc/sensu/conf.d') }
    # resources from sensu::transport
    it { should contain_file('/etc/sensu/conf.d/transport.json') }
    # resources from sensu::client
    it { should contain_file('/etc/sensu/conf.d/client.json') }
    it { should contain_sensu_client_config('testfqdn.example.com').with_base_path('/etc/sensu/conf.d') }
  end

  context 'with sensu_etc_dir => /opt/etc/sensu' do
    let(:params) { {:sensu_etc_dir => '/opt/etc/sensu' } }

    # resources from sensu::package
    it { should contain_file('/opt/etc/sensu/conf.d') }
    it { should contain_file('/opt/etc/sensu/conf.d/handlers') }
    it { should contain_file('/opt/etc/sensu/conf.d/checks') }
    it { should contain_file('/opt/etc/sensu/conf.d/filters') }
    it { should contain_file('/opt/etc/sensu/conf.d/extensions') }
    it { should contain_file('/opt/etc/sensu/conf.d/mutators') }
    it { should contain_file('/opt/etc/sensu/conf.d/contacts') }
    it { should contain_file('/opt/etc/sensu/handlers') }
    it { should contain_file('/opt/etc/sensu/extensions') }
    it { should contain_file('/opt/etc/sensu/extensions/handlers') }
    it { should contain_file('/opt/etc/sensu/mutators') }
    it { should contain_file('/opt/etc/sensu/plugins') }
    it { should contain_file('/opt/etc/sensu/config.json') }
    # resources from sensu::rabbitmq::config
    it { should_not contain_file('/opt/etc/sensu/ssl') }
    it { should_not contain_file('/opt/etc/sensu/ssl/cert.pem').with_require('File[/opt/etc/sensu/ssl]') }
    it { should_not contain_file('/opt/etc/sensu/ssl/key.pem').with_require('File[/opt/etc/sensu/ssl]') }
    it { should contain_file('/opt/etc/sensu/conf.d/rabbitmq.json') }
    it { should contain_sensu_rabbitmq_config('testfqdn.example.com').with_base_path('/opt/etc/sensu/conf.d') }
    # resources from sensu::redis::config
    it { should contain_file('/opt/etc/sensu/conf.d/redis.json') }
    it { should contain_sensu_redis_config('testfqdn.example.com').with_base_path('/opt/etc/sensu/conf.d') }
    # resources from sensu::api
    it { should contain_file('/opt/etc/sensu/conf.d/api.json') }
    it { should contain_sensu_api_config('testfqdn.example.com').with_base_path('/opt/etc/sensu/conf.d') }
    # resources from sensu::enterprise::dashboard
    it { should_not contain_file('/opt/etc/sensu/dashboard.json') }
    # resources from sensu::subscription (positive tests are included in test for sensu::subscription itself)
    it { should_not contain_file('/opt/etc/sensu/conf.d/subscriptiond.json') }
    it { should_not contain_sensu_client_subscription('mysubscription').with_base_path('/opt/etc/sensu/conf.d') }
    # resources from sensu::transport
    it { should contain_file('/opt/etc/sensu/conf.d/transport.json') }
    # resources from sensu::client
    it { should contain_file('/opt/etc/sensu/conf.d/client.json') }
    it { should contain_sensu_client_config('testfqdn.example.com').with_base_path('/opt/etc/sensu/conf.d') }

    context 'when rabbitmq_ssl_cert_chain => puppet:///modules/sensu/cert.pem' do
      let(:params) { {:sensu_etc_dir => '/opt/etc/sensu', :rabbitmq_ssl_cert_chain => 'puppet:///modules/sensu/cert.pem' } }
      it { should contain_file('/opt/etc/sensu/ssl') }
      it { should contain_file('/opt/etc/sensu/ssl/cert.pem').with_require('File[/opt/etc/sensu/ssl]') }
      it { should_not contain_file('/opt/etc/sensu/ssl/key.pem') }
    end

    context 'when rabbitmq_ssl_private_key => puppet:///modules/sensu/key.pem' do
      let(:params) { {:sensu_etc_dir => '/opt/etc/sensu', :rabbitmq_ssl_private_key => 'puppet:///modules/sensu/key.pem' } }
      it { should contain_file('/opt/etc/sensu/ssl') }
      it { should_not contain_file('/opt/etc/sensu/ssl/cert.pem') }
      it { should contain_file('/opt/etc/sensu/ssl/key.pem').with_require('File[/opt/etc/sensu/ssl]') }
    end

    context 'when enterprise_dashboard => true (and enterprise_user & enterprise_pass set) ' do
      let(:params) { {:sensu_etc_dir => '/opt/etc/sensu', :enterprise_dashboard => true, :enterprise_user => 'user', :enterprise_pass => 'pass'  } }
      it { should contain_file('/opt/etc/sensu/dashboard.json') }
    end

    context 'when enterprise_dashboard => true (and enterprise_user & enterprise_pass set) ' do
      let(:params) { {:sensu_etc_dir => '/opt/etc/sensu', :enterprise_dashboard => true, :enterprise_user => 'user', :enterprise_pass => 'pass'  } }
      it { should contain_file('/opt/etc/sensu/dashboard.json') }
    end
  end

  describe 'osfamily windows defaults' do
    let(:facts) do
      {
        :osfamily => 'windows',
        :kernel   => 'windows',
        :operatingsystem => 'Windows',
        :os => {
          :architecture => 'x64',
          :release => {
            :major => '2012 R2',
          },
        },
      }
    end

    # FIXME: The following resource checks are only testing $sensu_etc_dir specific values
    # resources from sensu::package
    it { should contain_file('C:/opt/sensu/conf.d') }
    it { should contain_file('C:/opt/sensu/conf.d/handlers') }
    it { should contain_file('C:/opt/sensu/conf.d/checks') }
    it { should contain_file('C:/opt/sensu/conf.d/filters') }
    it { should contain_file('C:/opt/sensu/conf.d/extensions') }
    it { should contain_file('C:/opt/sensu/conf.d/mutators') }
    it { should contain_file('C:/opt/sensu/conf.d/contacts') }
    it { should contain_file('C:/opt/sensu/handlers') }
    it { should contain_file('C:/opt/sensu/extensions') }
    it { should contain_file('C:/opt/sensu/extensions/handlers') }
    it { should contain_file('C:/opt/sensu/mutators') }
    it { should contain_file('C:/opt/sensu/plugins') }
    it { should contain_file('C:/opt/sensu/config.json') }
    # resources from sensu::rabbitmq::config
    it { should_not contain_file('C:/opt/sensu/ssl') }
    it { should_not contain_file('C:/opt/sensu/ssl/cert.pem').with_require('File[C:/opt/sensu/ssl]') }
    it { should_not contain_file('C:/opt/sensu/ssl/key.pem').with_require('File[C:/opt/sensu/ssl]') }
    it { should contain_file('C:/opt/sensu/conf.d/rabbitmq.json') }
    it { should contain_sensu_rabbitmq_config('testfqdn.example.com').with_base_path('C:/opt/sensu/conf.d') }
    # resources from sensu::redis::config
    it { should contain_file('C:/opt/sensu/conf.d/redis.json') }
    it { should contain_sensu_redis_config('testfqdn.example.com').with_base_path('C:/opt/sensu/conf.d') }
    # resources from sensu::api
    it { should contain_file('C:/opt/sensu/conf.d/api.json') }
    it { should contain_sensu_api_config('testfqdn.example.com').with_base_path('C:/opt/sensu/conf.d') }
    # resources from sensu::enterprise::dashboard
    it { should_not contain_file('C:/opt/sensu/dashboard.json') }
    # resources from sensu::transport
    it { should contain_file('C:/opt/sensu/conf.d/transport.json') }
    # resources from sensu::client
    it { should contain_file('C:/opt/sensu/conf.d/client.json') }
    it { should contain_sensu_client_config('testfqdn.example.com').with_base_path('C:/opt/sensu/conf.d') }

    describe 'with manage_user => true' do
      it { should_not contain_user('sensu') }
    end

    describe 'with manage_user => false' do
      let(:params) { {:manage_user => false} }
      it { should_not contain_user('sensu') }
    end

    describe 'with sensu_user => Administrateur and sensu_group => Administrateurs' do
      let(:params) do
        {:sensu_user  => 'Administrateur',
         :sensu_group => 'Administrateurs'}
      end
      it { should contain_file('C:/opt/sensu/conf.d').with({:owner => 'Administrateur', :group => 'Administrateurs'}) }
    end

    context 'with sensu_etc_dir => C:/etc/sensu' do
      let(:params) { {:sensu_etc_dir => 'C:/etc/sensu' } }
      # resources from sensu::package
      it { should contain_file('C:/etc/sensu/conf.d') }
      it { should contain_file('C:/etc/sensu/conf.d/handlers') }
      it { should contain_file('C:/etc/sensu/conf.d/checks') }
      it { should contain_file('C:/etc/sensu/conf.d/filters') }
      it { should contain_file('C:/etc/sensu/conf.d/extensions') }
      it { should contain_file('C:/etc/sensu/conf.d/mutators') }
      it { should contain_file('C:/etc/sensu/conf.d/contacts') }
      it { should contain_file('C:/etc/sensu/handlers') }
      it { should contain_file('C:/etc/sensu/extensions') }
      it { should contain_file('C:/etc/sensu/extensions/handlers') }
      it { should contain_file('C:/etc/sensu/mutators') }
      it { should contain_file('C:/etc/sensu/plugins') }
      it { should contain_file('C:/etc/sensu/config.json') }
      # resources from sensu::rabbitmq::config
      it { should_not contain_file('C:/etc/sensu/ssl') }
      it { should_not contain_file('C:/etc/sensu/ssl/cert.pem').with_require('File[C:/etc/sensu/ssl]') }
      it { should_not contain_file('C:/etc/sensu/ssl/key.pem').with_require('File[C:/etc/sensu/ssl]') }
      it { should contain_file('C:/etc/sensu/conf.d/rabbitmq.json') }
      it { should contain_sensu_rabbitmq_config('testfqdn.example.com').with_base_path('C:/etc/sensu/conf.d') }
      # resources from sensu::redis::config
      it { should contain_file('C:/etc/sensu/conf.d/redis.json') }
      it { should contain_sensu_redis_config('testfqdn.example.com').with_base_path('C:/etc/sensu/conf.d') }
      # resources from sensu::api
      it { should contain_file('C:/etc/sensu/conf.d/api.json') }
      it { should contain_sensu_api_config('testfqdn.example.com').with_base_path('C:/etc/sensu/conf.d') }
      # resources from sensu::enterprise::dashboard
      it { should_not contain_file('C:/etc/sensu/dashboard.json') }
      # resources from sensu::transport
      it { should contain_file('C:/etc/sensu/conf.d/transport.json') }
      # resources from sensu::client
      it { should contain_file('C:/etc/sensu/conf.d/client.json') }
      it { should contain_sensu_client_config('testfqdn.example.com').with_base_path('C:/etc/sensu/conf.d') }

      context 'when rabbitmq_ssl_cert_chain => puppet:///modules/sensu/cert.pem' do
        let(:params) { {:sensu_etc_dir => 'C:/etc/sensu', :rabbitmq_ssl_cert_chain => 'puppet:///modules/sensu/cert.pem' } }
        it { should contain_file('C:/etc/sensu/ssl') }
        it { should contain_file('C:/etc/sensu/ssl/cert.pem').with_require('File[C:/etc/sensu/ssl]') }
        it { should_not contain_file('C:/etc/sensu/ssl/key.pem') }
      end

      context 'when rabbitmq_ssl_private_key => puppet:///modules/sensu/key.pem' do
        let(:params) { {:sensu_etc_dir => 'C:/etc/sensu', :rabbitmq_ssl_private_key => 'puppet:///modules/sensu/key.pem' } }
        it { should contain_file('C:/etc/sensu/ssl') }
        it { should_not contain_file('C:/etc/sensu/ssl/cert.pem') }
        it { should contain_file('C:/etc/sensu/ssl/key.pem').with_require('File[C:/etc/sensu/ssl]') }
      end

      context 'when enterprise_dashboard => true (and enterprise_user & enterprise_pass set) ' do
        let(:params) { {:sensu_etc_dir => 'C:/etc/sensu', :enterprise_dashboard => true, :enterprise_user => 'user', :enterprise_pass => 'pass'  } }
        it { should contain_file('C:/etc/sensu/dashboard.json') }
      end
    end

    context 'with default setting' do
      content = <<-END.gsub(/^\s+\|/, '')
        |<!-- Windows service definition for Sensu -->
        |<service>
        |  <id>sensu-client</id>
        |  <name>Sensu Client</name>
        |  <description>This service runs a Sensu Client</description>
        |  <executable>C:\\opt\\sensu\\embedded\\bin\\ruby</executable>
        |  <arguments>C:\\opt\\sensu\\embedded\\bin\\sensu-client -d C:\\opt\\sensu\\conf.d -L info</arguments>
        |  <logpath>C:\\opt\\sensu\\</logpath>
        |</service>
      END

      it do
        should contain_file('C:/opt/sensu/bin/sensu-client.xml').with({
          'ensure'  => 'file',
          'content' => content,
        })
      end

      it { should_not contain_user('sensu') }
    end

    context 'with log_level => debug' do
      let(:params) { {:log_level => 'debug' } }
      it { should contain_file('C:/opt/sensu/bin/sensu-client.xml').with_content(%r{^\s*<arguments>C:\\opt\\sensu\\embedded\\bin\\sensu-client -d C:\\opt\\sensu\\conf.d -L debug</arguments>$}) }
    end

    context 'with windows_logrotate => true' do
      let(:params) { {:windows_logrotate => true } }
      content = <<-END.gsub(/^\s+\|/, '')
        |<!-- Windows service definition for Sensu -->
        |<service>
        |  <id>sensu-client</id>
        |  <name>Sensu Client</name>
        |  <description>This service runs a Sensu Client</description>
        |  <executable>C:\\opt\\sensu\\embedded\\bin\\ruby</executable>
        |  <arguments>C:\\opt\\sensu\\embedded\\bin\\sensu-client -d C:\\opt\\sensu\\conf.d -L info</arguments>
        |  <logpath>C:\\opt\\sensu\\</logpath>
        |  <log mode="roll-by-size">
        |        <sizeThreshold>10240</sizeThreshold>
        |        <keepFiles>10</keepFiles>
        |  </log>
        |</service>
      END
      it { should contain_file('C:/opt/sensu/bin/sensu-client.xml').with_content(content) }
    end

    # without windows_logrotate => true windows_log_size will be ignored
    context 'windows_log_size => 242' do
      let(:params) { {:windows_log_size => '242' } }
      it { should contain_file('C:/opt/sensu/bin/sensu-client.xml').without_content(%r{^\s*<sizeThreshold>.*</sizeThreshold>$}) }
    end

    context 'windows_logrotate => true & windows_log_size => 242' do
      let(:params) { {:windows_logrotate => true, :windows_log_size => '242' } }
      it { should contain_file('C:/opt/sensu/bin/sensu-client.xml').with_content(%r{^\s*<sizeThreshold>242</sizeThreshold>$}) }
    end

    # without windows_logrotate => true windows_log_number will be ignored
    context 'windows_log_number => 242' do
      let(:params) { {:windows_log_number => '242' } }
      it { should contain_file('C:/opt/sensu/bin/sensu-client.xml').without_content(%r{^\s*<keepFiles>.*</keepFiles>$}) }
    end

    context 'windows_logrotate => true & windows_log_number => 242' do
      let(:params) { {:windows_logrotate => true, :windows_log_number => '242' } }
      it { should contain_file('C:/opt/sensu/bin/sensu-client.xml').with_content(%r{^\s*<keepFiles>242</keepFiles>$}) }
    end

    context 'with manage_user => false' do
      let(:params) { {:manage_user => false} }
      it { should_not contain_user('sensu') }
    end
  end

  context 'with use_embedded_ruby => false' do
    let(:params) { {:use_embedded_ruby => false } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^EMBEDDED_RUBY=false$}) }
  end

  context 'with log_level => debug' do
    let(:params) { {:log_level => 'debug' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_LEVEL=debug$}) }
  end

  context 'with log_dir => /var/log/tests' do
    let(:params) { {:log_dir => '/var/log/tests' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^LOG_DIR=/var/log/tests$}) }
  end

  context 'rubyopt => -rbundler/test' do
    let(:params) { {:rubyopt => '-rbundler/test' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^RUBYOPT="-rbundler/test"$}) }
  end

  context 'gem_path => /path/to/gems' do
    let(:params) { {:gem_path => '/path/to/gems' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^GEM_PATH="/path/to/gems"$}) }
  end

  context 'deregister_on_stop => true' do
    let(:params) { {:deregister_on_stop => true } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=""$}) }
  end

  # without deregister_on_stop == true deregister_handler will be ignored
  context 'deregister_handler => testing' do
    let(:params) { {:deregister_handler => 'testing' } }
    it { should contain_file('/etc/default/sensu').without_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER=.*$}) }
  end

 context 'deregister_on_stop => true & deregister_handler => testing' do
    let(:params) { {:deregister_on_stop => true, :deregister_handler => 'testing' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CLIENT_DEREGISTER_ON_STOP=true\nCLIENT_DEREGISTER_HANDLER="testing"$}) }
  end

  context 'init_stop_max_wait => 242' do
    let(:params) { {:init_stop_max_wait => 242 } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^SERVICE_MAX_WAIT="242"$}) }
  end

  context 'path => /spec/tests' do
    let(:params) { {:path => '/spec/tests' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^PATH=/spec/tests$}) }
  end

  context 'confd_dir => /spec/tests' do
    let(:params) { {:confd_dir => '/spec/tests' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CONFD_DIR="/etc/sensu/conf\.d,/spec/tests"$}) }
  end

  context 'confd_dir => [/spec/tests,/more/tests]' do
    let(:params) { {:confd_dir => ['/spec/tests', '/more/tests'] } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^CONFD_DIR="/etc/sensu/conf\.d,/spec/tests,/more/tests"$}) }
  end

  context 'heap_size => 256' do
    let(:params) { {:heap_size => 256 } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^HEAP_SIZE="256"$}) }
  end

  context 'heap_size => "256M"' do
    let(:params) { {:heap_size => '256M' } }
    it { should contain_file('/etc/default/sensu').with_content(%r{^HEAP_SIZE="256M"$}) }
  end

  context 'with plugins => puppet:///data/sensu/plugins/teststring.rb' do
    let(:params) { {:plugins => 'puppet:///data/sensu/plugins/teststring.rb' } }
    it { should contain_sensu__plugin('puppet:///data/sensu/plugins/teststring.rb') }
  end

  context 'with plugins => [ puppet:///test/array1.rb, puppet:///test/array2.rb ]' do
    let(:params) { {:plugins => [ 'puppet:///test/array1.rb', 'puppet:///test/array2.rb' ] } }
    it { should contain_sensu__plugin('puppet:///test/array1.rb') }
    it { should contain_sensu__plugin('puppet:///test/array2.rb') }
  end

  context 'with plugins set to a valid hash containing two entries with different options' do
    let(:params) { { :plugins => { 'puppet:///spec/testhash1.rb' => { 'pkg_version' => '2.4.2' }, 'puppet:///spec/testhash2.rb' => { 'install_path' => '/spec/testhash2' } } } }
    it { should contain_sensu__plugin('puppet:///spec/testhash1.rb').with_pkg_version('2.4.2') }
    it { should contain_sensu__plugin('puppet:///spec/testhash2.rb').with_install_path('/spec/testhash2') }
  end

  context 'with plugins_defaults set to { install_path => /test/path } and plugins set to a valid hash' do
    let(:params) do
      {
        :plugins_defaults => {
          'install_path' => '/test/path'
        },
        :plugins => {
          'puppet:///spec/testhash1.rb' => {
            'pkg_version' => '2.4.2',
          },
          'puppet:///spec/testhash2.rb' => {
            'pkg_provider' => 'sensu-gem',
          },
        },
      }
    end

    it do
      should contain_sensu__plugin('puppet:///spec/testhash1.rb').with({
        'install_path' => '/test/path',
        'pkg_version'  => '2.4.2',
      })
    end
    it do
      should contain_sensu__plugin('puppet:///spec/testhash2.rb').with({
        'install_path' => '/test/path',
        'pkg_provider' => 'sensu-gem',
      })
    end
  end

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

    it { should contain_sensu__check('some-check').with(
      :type        => 'pipe',
      :command     => '/usr/local/bin/some-check',
      :occurrences => '1',
      :handlers    => ['email']
    ) }
    it { should contain_file('/etc/sensu/conf.d/checks/some-check.json') }

    it { should contain_sensu__check('check-cpu').with(
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

  describe '(GH-688) default behavior of sensu_plugin_provider' do
    it 'should be sensu_gem ' do
      should contain_package('sensu-plugin').with(:provider => 'sensu_gem')
    end
  end

  describe 'variable type and content validations' do
    mandatory_params = {}

    validations = {
      'absolute_path' => {
        :name    => %w[log_dir path sensu_etc_dir],
        :valid   => %w[/absolute/filepath /absolute/directory/],
        :invalid => ['./relative/path', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
      'boolean' => {
        :name    => %w(deregister_on_stop),
        :valid   => [true, false],
        :invalid => ['false', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
      'integer' => {
        :name    => %w(init_stop_max_wait),
        :valid   => [3, '242'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 2.42, true, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
      'plugins' => {
        :name    => %w[plugins],
        :valid   => ['/string', %w(/array), { '/hash' => {} }],
        :invalid => [3, 2.42, true],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
      'validate_re log_level' => {
        :name    => %w[log_level],
        :valid   => %w[debug info warn error fatal],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::PreformattedError, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
