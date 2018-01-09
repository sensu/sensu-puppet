require 'spec_helper'

describe 'sensu', :type => :class do
  context 'config' do
    context 'service' do
      context 'running on Linux' do
        context 'with defaults for all parameters' do
          it { should contain_class('sensu::client') }
          it { should compile.with_all_deps }

          it do
            should contain_service('sensu-client').with({
              'ensure'     => 'running',
              'enable'     => 'true',
              'hasrestart' => 'true',
              'subscribe'  => [
                'Class[Sensu::Package]',
                'Sensu_client_config[testfqdn.example.com]',
                'Class[Sensu::Rabbitmq::Config]',
              ],
            })
          end

          it { should_not contain_file('C:/opt/sensu/bin/sensu-client.xml') }
          it { should_not contain_exec('install-sensu-client') }
        end
      end

      context 'running on Windows' do
        let(:facts) do
          {
            :osfamily => 'windows',
            :kernel   => 'windows',
            # needed for sensu::package
            :os => {
              :release => {
                :major => '2012 R2',
              },
            },
          }
        end

        context 'with defaults for all parameters' do
          it { should contain_class('sensu::client') }
          # FIXME: test causes issues in sensu::package
          # it { should compile.with_all_deps }

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

          it do
            should contain_exec('install-sensu-client').with({
              'provider' => 'powershell',
              'command'  => "New-Service -Name sensu-client -BinaryPathName c:\\opt\\sensu\\bin\\sensu-client.exe -DisplayName 'Sensu Client' -StartupType Automatic",
              'unless'   => 'if (Get-Service sensu-client -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }',
              'before'   => 'Service[sensu-client]',
              'require'  => 'File[C:/opt/sensu/bin/sensu-client.xml]',
            })
          end

          it do
            should contain_service('sensu-client').with({
              'ensure'     => 'running',
              'enable'     => 'true',
              'hasrestart' => 'true',
              'subscribe'  => [
                'Class[Sensu::Package]',
                'Sensu_client_config[testfqdn.example.com]',
                'Class[Sensu::Rabbitmq::Config]',
              ],
            })
          end
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
      end
    end

    context 'with hasrestart => false' do
      let(:params) { { :hasrestart => false } }
      it { should contain_service('sensu-client').with_hasrestart(false) }
    end



    describe 'variable type and content validations' do
      mandatory_params = {}

      validations = {
        'boolean' => {
          :name    => %w(hasrestart),
          :valid   => [true, false],
          :invalid => ['false', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
          :message => 'is not a boolean',
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
                expect { should contain_class(subject) }.to raise_error(Puppet::PreformattedError)
              end
            end
          end
        end # var[:name].each
      end # validations.sort.each
    end # describe 'variable type and content validations'
  end
end
