require 'spec_helper_acceptance'

# Note: sensu_plugin provider and sensu-plugins-ruby package are deprecated
# Modern approach uses sensuctl asset add to install Bonsai assets
# This test uses Bonsai assets instead of the deprecated Ruby plugin system
describe 'sensu assets (modern plugin replacement)', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'install Bonsai assets' do
    it 'should work without errors' do
      pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
}
# Use Bonsai assets instead of deprecated sensu-plugins-ruby
exec { 'add sensu-ruby-runtime asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/sensu-ruby-runtime',
  unless  => 'sensuctl asset info sensu/sensu-ruby-runtime',
  require => Sensuctl_configure['puppet'],
}
exec { 'add sensu-plugins-cpu-checks asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu-plugins/sensu-plugins-cpu-checks',
  unless  => 'sensuctl asset info sensu-plugins/sensu-plugins-cpu-checks',
  require => Sensuctl_configure['puppet'],
}
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
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

    it 'should have sensu-ruby-runtime asset installed' do
      on node, 'sensuctl asset info sensu/sensu-ruby-runtime --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['name']).to eq('sensu/sensu-ruby-runtime')
      end
    end

    it 'should have sensu-plugins-cpu-checks asset installed' do
      on node, 'sensuctl asset info sensu-plugins/sensu-plugins-cpu-checks --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['name']).to eq('sensu-plugins/sensu-plugins-cpu-checks')
      end
    end
  end

  context 'list assets' do
    it 'should list all installed assets' do
      on node, 'sensuctl asset list --format json' do |result|
        data = JSON.parse(result.stdout)
        asset_names = data.map { |a| a['metadata']['name'] }
        expect(asset_names).to include('sensu/sensu-ruby-runtime')
        expect(asset_names).to include('sensu-plugins/sensu-plugins-cpu-checks')
      end
    end
  end

  context 'remove assets' do
    it 'should work without errors' do
      pp = <<~EOS
class { '::sensu':
  password => 'supersecret',
  use_ssl => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}
class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/certs/cert.pem',
  ssl_key_source => '/etc/puppetlabs/puppet/ssl/private_keys/key.pem',
}
# Remove assets using sensu_asset resource
# Note: These assets were added via sensuctl asset add, which creates
# them with specific names in the Bonsai format
sensu_asset { 'sensu-plugins/sensu-plugins-cpu-checks':
  ensure => 'absent',
}
sensu_asset { 'sensu/sensu-ruby-runtime':
  ensure => 'absent',
}
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
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

    it 'should have assets removed' do
      on node, 'sensuctl asset list --format json' do |result|
        data = JSON.parse(result.stdout)
        asset_names = data.map { |a| a['metadata']['name'] }
        expect(asset_names).not_to include('sensu-plugins/sensu-plugins-cpu-checks')
        expect(asset_names).not_to include('sensu/sensu-ruby-runtime')
      end
    end
  end
end
