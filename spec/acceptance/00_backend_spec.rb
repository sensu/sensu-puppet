require 'spec_helper_acceptance'

describe 'sensu::backend class', unless: RSpec.configuration.sensu_cluster do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'with SSL' do
    it 'should bootstrap certs' do
      on node, 'mkdir -p /root/ssl'
      on node, 'openssl req -newkey rsa:2048 -nodes -keyout /root/ssl/ca_key.pem -x509 -days 365 -out /root/ssl/ca.pem -subj "/CN=localhost"'
      on node, 'openssl req -newkey rsa:2048 -nodes -keyout /root/ssl/key.pem -out /root/ssl/localhost.csr -subj "/CN=localhost"'
      on node, 'openssl x509 -req -in /root/ssl/localhost.csr -CA /root/ssl/ca.pem -CAkey /root/ssl/ca_key.pem -CAcreateserial -out /root/ssl/cert.pem -days 365 -sha256'
      if fact_on(node, 'os.family') == 'Debian'
        on node, 'apt-get install ca-certificates'
        on node, 'cp /root/ssl/ca.pem /usr/local/share/ca-certificates/ca.crt'
        on node, 'PATH=/usr/bin:/bin:/usr/sbin:/sbin update-ca-certificates'
      elsif fact_on(node, 'os.family') == 'RedHat'
        on node, 'cat /root/ssl/ca.pem >> /etc/pki/tls/certs/ca-bundle.crt'
      end
      # Force sensuctl configure to re-run
      on node, 'rm -f /root/.config/sensu/sensuctl/cluster'
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
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('sensuctl entity list'), :node => node do
      its(:exit_status) { should eq 0 }
    end
  end

  context 'reset to default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      EOS

      # Force re-run of sensuctl configure
      on node, 'rm -f /root/.config/sensu/sensuctl/cluster'
      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe service('sensu-backend'), :node => node do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('sensuctl entity list'), :node => node do
      its(:exit_status) { should eq 0 }
    end
  end
end
