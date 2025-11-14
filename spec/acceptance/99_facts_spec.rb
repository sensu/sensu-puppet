require 'spec_helper_acceptance'

describe 'sensu::backend class', if: ['base'].include?(RSpec.configuration.sensu_mode) do
  backend = hosts_as('sensu-backend')[0]
  agent = hosts_as('sensu-agent')[0]
  let(:facter_command) do |result|
    puppet_version = on(backend, 'puppet --version').stdout
    if Gem::Version.new(puppet_version) >= Gem::Version.new('7.0.0')
      'puppet facts show'
    else
      'facter -p --json'
    end
  end

  context 'backend facts' do
    it 'should work without errors' do
      pp = <<~EOS
class { '::sensu':
  password => 'P@ssw0rd!',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  include_agent_resources => false,
}
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
      else
        apply_manifest_on(backend, pp, :catch_failures => true)
        # Simulate plugin sync
        fact_path = File.join(File.dirname(__FILE__), '../..', 'lib/facter')
        scp_to(backend, fact_path, '/opt/puppetlabs/puppet/cache/lib/')
      end
    end

    it "should have backend facts" do
      # Apply the backend manifest to ensure it's installed
      pp = <<~EOS
class { '::sensu':
  password => 'P@ssw0rd!',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  include_agent_resources => false,
}
      EOS
      
      apply_manifest_on(backend, pp, :catch_failures => true)
      
      # Wait for backend package to be installed and available
      on backend, 'timeout 60 bash -c "while ! which sensu-backend; do sleep 2; done"'
      
      # Wait for backend service to be running
      on backend, 'timeout 60 bash -c "while ! systemctl is-active --quiet sensu-backend; do sleep 2; done"'
      
      # Copy facter files to ensure they're available
      fact_path = File.join(File.dirname(__FILE__), '../..', 'lib/facter')
      scp_to(backend, fact_path, '/opt/puppetlabs/puppet/cache/lib/')
      
      # Test the version command directly first
      on(backend, 'echo "=== DEBUGGING ==="')
      on(backend, 'sensu-backend version || echo "BACKEND VERSION FAILED"')
      
      # Wait a bit more for facter to be ready
      sleep(5)
      
      out = on(backend, "#{facter_command} sensu_backend_version").stdout
      data = JSON.parse(out)
      on(backend, "echo 'Fact result: #{data.inspect}'")
      expect(data['sensu_backend_version']).to match(/^[0-9\.]+/)
    end

    it "should have sensuctl facts" do
      # Apply the backend manifest to ensure sensuctl is installed
      pp = <<~EOS
class { '::sensu':
  password => 'P@ssw0rd!',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
  include_default_resources => false,
  include_agent_resources => false,
}
      EOS
      
      apply_manifest_on(backend, pp, :catch_failures => true)
      
      # Wait for sensuctl to be installed and available
      on backend, 'timeout 60 bash -c "while ! which sensuctl; do sleep 2; done"'
      
      # Wait for backend service to be running
      on backend, 'timeout 60 bash -c "while ! systemctl is-active --quiet sensu-backend; do sleep 2; done"'
      
      # Copy facter files to ensure they're available
      fact_path = File.join(File.dirname(__FILE__), '../..', 'lib/facter')
      scp_to(backend, fact_path, '/opt/puppetlabs/puppet/cache/lib/')
      
      # Debug version commands
      puts "=== DEBUGGING SENSUCTL VERSION COMMANDS ==="
      debug_output = on(backend, 'sensuctl version 2>&1 || echo "Command failed with exit code: $?"').stdout
      puts "sensuctl version output: #{debug_output}"
      
      debug_output = on(backend, 'which sensuctl').stdout
      puts "which sensuctl: #{debug_output}"
      
      # Wait a bit more for facter to be ready
      sleep(5)
      
      out = on(backend, "#{facter_command} sensuctl_version").stdout
      data = JSON.parse(out)
      puts "Fact result: #{data}"
      expect(data['sensuctl_version']).to match(/^[0-9\.]+/)
    end
  end

  context 'agent facts' do
    it 'should work without errors' do
      pp = <<~EOS
class { '::sensu':
  validate_api => false,
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
include sensu::agent
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
      else
        apply_manifest_on(agent, pp, :catch_failures => true)
        # Simulate plugin sync
        fact_path = File.join(File.dirname(__FILE__), '../..', 'lib/facter')
        scp_to(agent, fact_path, '/opt/puppetlabs/puppet/cache/lib/')
      end
    end

    it "should have agent facts" do
      # Apply the agent manifest to ensure it's installed
      pp = <<~EOS
class { '::sensu':
  validate_api => false,
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
include sensu::agent
      EOS
      
      apply_manifest_on(agent, pp, :catch_failures => true)
      
      # Wait for agent package to be installed and available
      on agent, 'timeout 60 bash -c "while ! which sensu-agent; do sleep 2; done"'
      
      # Wait for agent service to be running
      on agent, 'timeout 60 bash -c "while ! systemctl is-active --quiet sensu-agent; do sleep 2; done"'
      
      # Copy facter files to ensure they're available
      fact_path = File.join(File.dirname(__FILE__), '../..', 'lib/facter')
      scp_to(agent, fact_path, '/opt/puppetlabs/puppet/cache/lib/')
      
      # Wait a bit more for facter to be ready
      sleep(5)
      
      out = on(agent, "#{facter_command} sensu_agent_version").stdout
      data = JSON.parse(out)
      expect(data['sensu_agent_version']).to match(/^[0-9\.]+/)
    end
  end
end
