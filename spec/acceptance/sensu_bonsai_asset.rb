require 'spec_helper_acceptance'

describe 'sensu_bonsai_asset', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'install bonsai asset' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
        ensure  => 'present',
        version => '1.1.0',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have bonsai asset' do
      on node, 'sensuctl asset info sensu/sensu-pagerduty-handler --format json' do
        data = JSON.parse(stdout)
        version = data['metadata']['annotations']['io.sensu.bonsai.version']
        expect(version).to eq('1.1.0')
      end
    end
  end

  context 'install bonsai asset - latest' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
        ensure  => 'present',
        version => 'latest',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have bonsai asset' do
      on node, 'sensuctl asset info sensu/sensu-pagerduty-handler --format json' do
        data = JSON.parse(stdout)
        version = data['metadata']['annotations']['io.sensu.bonsai.version']
        upgraded = (Gem::Version.new(version) > Gem::Version.new('1.1.0'))
        expect(version).not_to eq('1.1.0')
        expect(upgraded).to eq(true)
      end
    end
  end

  context 'downgrade bonsai asset' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
        ensure  => 'present',
        version => '1.1.0',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have bonsai asset' do
      on node, 'sensuctl asset info sensu/sensu-pagerduty-handler --format json' do
        data = JSON.parse(stdout)
        version = data['metadata']['annotations']['io.sensu.bonsai.version']
        expect(version).to eq('1.1.0')
      end
    end
  end

  context 'upgrade bonsai asset' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
        ensure  => 'present',
        version => '1.2.0',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have bonsai asset' do
      on node, 'sensuctl asset info sensu/sensu-pagerduty-handler --format json' do
        data = JSON.parse(stdout)
        version = data['metadata']['annotations']['io.sensu.bonsai.version']
        expect(version).to eq('1.2.0')
      end
    end
  end

  context 'asset purging' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
        ensure  => 'present',
        version => '1.2.0',
      }
      resources { 'sensu_asset': purge => true }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have bonsai asset' do
      on node, 'sensuctl asset info sensu/sensu-pagerduty-handler --format json' do
        data = JSON.parse(stdout)
        version = data['metadata']['annotations']['io.sensu.bonsai.version']
        expect(version).to eq('1.2.0')
      end
    end
  end

  context 'remove bonsai asset' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
        ensure  => 'absent',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu_backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe command('sensuctl asset info sensu/sensu-pagerduty-handler'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end
