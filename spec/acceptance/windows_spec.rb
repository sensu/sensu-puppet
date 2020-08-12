require 'spec_helper_acceptance_windows' if Gem.win_platform?
require 'json'

describe 'sensu::cli class', if: Gem.win_platform? do
  context 'default' do
    pp = <<-EOS
    class { '::sensu':
      use_ssl  => false,
      api_host => 'localhost',
    }
    class { 'sensu::cli':
      install_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.20.1/sensu-go_5.20.1_windows_amd64.zip',
    }
    EOS

    unless RSpec.configuration.skip_apply
      it 'creates manifest' do
        File.open('C:\manifest-cli.pp', 'w') { |f| f.write(pp) }
        puts "C:\manifest-cli.pp"
        puts File.read('C:\manifest-cli.pp')
      end

      describe command('puppet apply --debug --detailed-exitcodes C:\manifest-cli.pp ; Write-Output "EXITCODE=$LastExitCode"') do
        its(:stdout) { is_expected.to match /EXITCODE=2/ }
      end
      describe command('puppet apply --debug --detailed-exitcodes C:\manifest-cli.pp ; Write-Output "EXITCODE=$LastExitCode"') do
        its(:stdout) { is_expected.to match /EXITCODE=0/ }
      end

      describe file('C:/Program Files/Sensu/sensuctl.exe') do
        it { should exist }
      end
      describe 'sensuctl.version fact' do
        it 'has version fact' do
          output = `facter --json -p sensuctl`
          data = JSON.parse(output.strip)
          expect(data['sensuctl']['version']).to match(/^[0-9\.]+/)
        end
      end
    end
  end
end

describe 'sensu::agent class', if: Gem.win_platform? do
  context 'default' do
    pp = <<-EOS
    class { '::sensu':
      use_ssl  => false,
      api_host => 'localhost',
    }
    class { 'sensu::agent':
      backends         => ['localhost:8081'],
      entity_name      => 'sensu-agent',
      subscriptions    => ['base'],
      service_env_vars => { 'SENSU_API_PORT' => '4041' },
      config_hash      => {
        'log-level' => 'info',
      }
    }
    sensu::agent::subscription { 'windows': }
    EOS

    unless RSpec.configuration.skip_apply
      it 'creates manifest' do
        File.open('C:\manifest-agent.pp', 'w') { |f| f.write(pp) }
        puts "C:\manifest-agent.pp"
        puts File.read('C:\manifest-agent.pp')
      end

      describe command('puppet apply --debug --detailed-exitcodes C:\manifest-agent.pp ; Write-Output "EXITCODE=$LastExitCode"') do
        its(:stdout) { is_expected.to match /EXITCODE=2/ }
      end
      describe command('puppet apply --debug --detailed-exitcodes C:\manifest-agent.pp ; Write-Output "EXITCODE=$LastExitCode"') do
        its(:stdout) { is_expected.to match /EXITCODE=0/ }
      end

      describe file('C:\ProgramData\Sensu\config\agent.yml') do
        expected_content = {
          'backend-url'     => ['ws://localhost:8081'],
          'password'        => 'P@ssw0rd!',
          'name'            => 'sensu-agent',
          'subscriptions'   => ['base','windows'],
          'redact'          => ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret'],
          'log-level'       => 'info',
        }
        its(:content_as_yaml) { is_expected.to eq(expected_content) }
      end
    end
    describe service('SensuAgent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe 'sensu_agent.version fact' do
      it 'has version fact' do
        output = `facter --json -p sensu_agent`
        data = JSON.parse(output.strip)
        expect(data['sensu_agent']['version']).to match(/^[0-9\.]+/)
      end
    end
  end

  context 'using package_source' do
    pp = <<-EOS
    class { '::sensu':
      use_ssl  => false,
      api_host => 'localhost',
    }
    class { 'sensu::agent':
      package_name   => 'Sensu Agent',
      package_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.20.1/sensu-go-agent_5.20.1.12427_en-US.x64.msi',
      backends       => ['localhost:8081'],
      entity_name    => 'sensu-agent',
      config_hash    => {
        'log-level' => 'info',
      }
    }
    EOS

    unless RSpec.configuration.skip_apply
      it 'creates manifest' do
        File.open('C:\manifest-agent.pp', 'w') { |f| f.write(pp) }
        puts "C:\manifest-agent.pp"
        puts File.read('C:\manifest-agent.pp')
      end

      describe command('puppet resource package sensu-agent ensure=absent provider=chocolatey') do
        its(:exit_status) { is_expected.to eq 0 }
      end

      describe command('puppet apply --debug --detailed-exitcodes C:\manifest-agent.pp ; Write-Output "EXITCODE=$LastExitCode"') do
        its(:stdout) { is_expected.to match /EXITCODE=2/ }
      end
      describe command('puppet apply --debug --detailed-exitcodes C:\manifest-agent.pp ; Write-Output "EXITCODE=$LastExitCode"') do
        its(:stdout) { is_expected.to match /EXITCODE=0/ }
      end
    end

    describe service('SensuAgent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(4041) do
      it { should be_listening }
    end
    describe 'sensu_agent.version fact' do
      it 'has version fact' do
        output = `facter --json -p sensu_agent`
        data = JSON.parse(output.strip)
        expect(data['sensu_agent']['version']).to match(/^[0-9\.]+/)
      end
    end
  end
end
