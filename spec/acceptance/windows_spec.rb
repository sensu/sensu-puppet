require 'spec_helper_acceptance_windows' if Gem.win_platform?
require 'json'

describe 'sensu::cli class', if: Gem.win_platform? do
  context 'default' do
    pp = <<-EOS
    class { '::sensu':
      api_host => 'localhost',
    }
    class { 'sensu::cli':
      install_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.14.1/sensu-go_5.14.1_windows_amd64.zip',
      # Not yet able to run backend in appveyor so configure will not work
      configure      => false,
    }
    EOS

    unless RSpec.configuration.skip_apply
      it 'creates manifest' do
        File.open('C:\manifest-cli.pp', 'w') { |f| f.write(pp) }
        puts "C:\manifest-cli.pp"
        puts File.read('C:\manifest-cli.pp')
      end

      describe command('puppet apply --debug C:\manifest-cli.pp') do
        its(:exit_status) { is_expected.to eq 0 }
      end

      describe file('C:/Program Files/Sensu/sensuctl.exe') do
        it { should exist }
      end
      describe 'sensuctl.version fact' do
        it 'has version fact' do
          output = `facter --json -p sensuctl`
          data = JSON.parse(output.strip)
          expect(data['sensuctl']['version']).to match(/^[0-9\.]+$/)
        end
      end
    end
  end
end

describe 'sensu::agent class', if: Gem.win_platform? do
  context 'default' do
    pp = <<-EOS
    class { '::sensu': }
    class { 'sensu::agent':
      backends         => ['sensu_backend:8081'],
      entity_name      => 'sensu_agent',
      service_env_vars => { 'SENSU_API_PORT' => '4041' },
      config_hash      => {
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

      describe command('puppet apply --debug C:\manifest-agent.pp') do
        its(:exit_status) { is_expected.to eq 0 }
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
        expect(data['sensu_agent']['version']).to match(/^[0-9\.]+$/)
      end
    end
  end

  context 'using package_source' do
    pp = <<-EOS
    class { '::sensu': }
    class { 'sensu::agent':
      package_name   => 'Sensu Agent',
      package_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.13.1/sensu-go-agent_5.13.1.5957_en-US.x64.msi',
      backends       => ['sensu_backend:8081'],
      entity_name    => 'sensu_agent',
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

      describe command('puppet apply --debug C:\manifest-agent.pp') do
        its(:exit_status) { is_expected.to eq 0 }
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
        expect(data['sensu_agent']['version']).to match(/^[0-9\.]+$/)
      end
    end
  end
end
