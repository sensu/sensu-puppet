require 'spec_helper_acceptance'

describe 'sensu with SSL', unless: RSpec.configuration.sensu_cluster do
  backend = only_host_with_role(hosts, 'sensu_backend')
  agent = only_host_with_role(hosts, 'sensu_agent')
  context 'backend' do
    it 'should bootstrap certs' do
      ssl_path = File.join(File.dirname(__FILE__), '../..', 'tests/ssl')
      scp_to(backend, ssl_path, '/root/ssl')
      if fact_on(backend, 'os.family') == 'Debian'
        on backend, 'apt-get install ca-certificates'
        on backend, 'cp /root/ssl/ca.pem /usr/local/share/ca-certificates/ca.crt'
        on backend, 'PATH=/usr/bin:/bin:/usr/sbin:/sbin update-ca-certificates'
      elsif fact_on(backend, 'os.family') == 'RedHat'
        on backend, 'cat /root/ssl/ca.pem >> /etc/pki/tls/certs/ca-bundle.crt'
      end
    end
    it 'should work without errors' do
      pp = <<-EOS
      file { '/etc/sensu/ssl':
        ensure  => 'directory',
        source  => '/root/ssl',
        recurse => true,
        notify  => Service['sensu-backend'],
      }
      class { '::sensu::backend':
        url_host    => 'localhost',
        use_ssl     => true,
        config_hash => {
          'cert-file'       => '/etc/sensu/ssl/cert.pem',
          'key-file'        => '/etc/sensu/ssl/key.pem',
          'trusted-ca-file' => '/etc/sensu/ssl/ca.pem',
        },
      }
      sensu_entity { 'sensu_agent':
        ensure => 'absent',
      }
      EOS

      # Ensure agent entity doesn't get re-added
      on agent, 'puppet resource service sensu-agent ensure=stopped'
      apply_manifest_on(backend, pp, :catch_failures => true)
      apply_manifest_on(backend, pp, :catch_changes  => true)
    end

    describe service('sensu-backend'), :node => backend do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('sensuctl entity list'), :node => backend do
      its(:exit_status) { should eq 0 }
    end
  end

  context 'agent' do
    it 'should bootstrap certs' do
      ssl_path = File.join(File.dirname(__FILE__), '../..', 'tests/ssl')
      scp_to(agent, ssl_path, '/root/ssl')
      if fact_on(agent, 'os.family') == 'Debian'
        on agent, 'apt-get install ca-certificates'
        on agent, 'cp /root/ssl/ca.pem /usr/local/share/ca-certificates/ca.crt'
        on agent, 'PATH=/usr/bin:/bin:/usr/sbin:/sbin update-ca-certificates'
      elsif fact_on(agent, 'os.family') == 'RedHat'
        on agent, 'cat /root/ssl/ca.pem >> /etc/pki/tls/certs/ca-bundle.crt'
      end
    end
    it 'should work without errors' do
      pp = <<-EOS
      class { '::sensu::agent':
        config_hash => {
          'name'        => 'sensu_agent',
          'backend-url' => 'wss://sensu_backend:8081',
        }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(agent, pp, :catch_failures => true)
      apply_manifest_on(agent, pp, :catch_changes  => true)
    end

    describe service('sensu-agent'), :node => agent do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('sensuctl entity info sensu_agent'), :node => backend do
      its(:exit_status) { should eq 0 }
    end
  end
end
