require 'spec_helper_acceptance'

describe 'sensu::backend class', if: ['base','full'].include?(RSpec.configuration.sensu_mode) do
  backend = hosts_as('sensu-backend')[0]
  agent = hosts_as('sensu-agent')[0]
  let(:facter_command) do
    puppet_version = on(backend, 'puppet --version').stdout
    if Gem::Version.new(puppet_version) >= Gem::Version.new('7.0.0')
      'puppet facts show'
    else
      'facter -p --json'
    end
  end

  context 'backend facts' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
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
      out = on(backend, "#{facter_command} sensu_backend.version").stdout
      data = JSON.parse(out)
      expect(data['sensu_backend.version']).to match(/^[0-9\.]+/)
    end

    it "should have sensuctl facts" do
      out = on(backend, "#{facter_command} sensuctl.version").stdout
      data = JSON.parse(out)
      expect(data['sensuctl.version']).to match(/^[0-9\.]+/)
    end
  end

  context 'agent facts' do
    it 'should work without errors' do
      pp = <<-EOS
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
      out = on(agent, "#{facter_command} sensu_agent.version").stdout
      data = JSON.parse(out)
      expect(data['sensu_agent.version']).to match(/^[0-9\.]+/)
    end
  end
end
