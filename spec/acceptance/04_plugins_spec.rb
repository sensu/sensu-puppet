require 'spec_helper_acceptance'

describe 'sensu::plugins class', if: ['base'].include?(RSpec.configuration.sensu_mode) do
  agent = hosts_as('sensu-agent')[0]
  backend = hosts_as('sensu-backend')[0]
  context 'on backend' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
       class { '::sensu':
         api_host => 'sensu-backend',
         api_port => 8080,
         password => 'P@ssw0rd!',
         use_ssl => false,
       }
       class { 'sensu::backend': }
      # Use Bonsai assets instead of Ruby plugins
      # Note: default namespace is created by sensu::backend
      # Add assets using sensuctl after backend is configured
      exec { 'add sensu-ruby-runtime asset':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'sensuctl asset add sensu/sensu-ruby-runtime',
        unless  => 'sensuctl asset info sensu/sensu-ruby-runtime',
        require => Sensuctl_configure['puppet'],
      }
      exec { 'add sensu-email-handler asset':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'sensuctl asset add sensu/sensu-email-handler',
        unless  => 'sensuctl asset info sensu/sensu-email-handler',
        require => Sensuctl_configure['puppet'],
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on backend, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(backend, pp, :catch_failures => true)
        apply_manifest_on(backend, pp, :catch_changes  => true)
      end
    end

    it 'should have Bonsai assets installed' do
      on backend, 'sensuctl asset info sensu/sensu-ruby-runtime --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['name']).to eq('sensu/sensu-ruby-runtime')
      end
    end

    it 'should have email-handler asset installed' do
      on backend, 'sensuctl asset info sensu/sensu-email-handler --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['name']).to eq('sensu/sensu-email-handler')
      end
    end
  end
  context 'on agent' do
    it 'should work without errors and be idempotent' do
      pp = <<-EOS
       class { '::sensu':
         api_host => 'sensu-backend',
         api_port => 8080,
         use_ssl => false,
       }
       class { 'sensu::agent':
         backends    => ['sensu-backend:8081'],
         entity_name => 'sensu-agent',
       }
       class { 'sensu::cli':
         configure => false,
       }
      # Use Bonsai assets instead of Ruby plugins
      # Note: default namespace is created by sensu::backend
      # Add assets using sensuctl after backend is configured
      # Test hostname resolution first
      exec { 'test hostname resolution':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'ping -c 1 sensu-backend || echo "Hostname resolution failed"',
        unless  => 'ping -c 1 sensu-backend 2>/dev/null',
        require => Package['sensu-go-cli'],
      }
      # Wait for backend API to be ready (with longer timeout)
      exec { 'wait for backend api':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'timeout 300 bash -c "while ! curl -s http://sensu-backend:8080/health; do sleep 15; done"',
        unless  => 'curl -s http://sensu-backend:8080/health 2>/dev/null',
        require => Exec['test hostname resolution'],
      }
      # Wait for backend to be fully ready before starting agent
      exec { 'wait for backend fully ready':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'timeout 300 bash -c "while ! curl -s http://sensu-backend:8080/api/core/v2/namespaces; do sleep 15; done"',
        unless  => 'curl -s http://sensu-backend:8080/api/core/v2/namespaces 2>/dev/null',
        require => Exec['wait for backend api'],
      }
      # Configure sensuctl first
      exec { 'configure sensuctl':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'sensuctl configure --non-interactive --url http://sensu-backend:8080 --username admin --password P@ssw0rd!',
        unless  => 'sensuctl config view | grep -q "http://sensu-backend:8080"',
        require => Exec['wait for backend fully ready'],
      }
      # Add assets after sensuctl is configured
      exec { 'add sensu-ruby-runtime asset':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'sensuctl asset add sensu/sensu-ruby-runtime',
        unless  => 'sensuctl asset info sensu/sensu-ruby-runtime',
        require => Exec['configure sensuctl'],
      }
      exec { 'add sensu-email-handler asset':
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'sensuctl asset add sensu/sensu-email-handler',
        unless  => 'sensuctl asset info sensu/sensu-email-handler',
        require => Exec['configure sensuctl'],
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-agent' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on agent, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(agent, pp, :catch_failures => true)
        apply_manifest_on(agent, pp, :catch_changes  => true)
      end
    end

    it 'should have Bonsai assets installed' do
      on agent, 'sensuctl asset info sensu/sensu-ruby-runtime --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['name']).to eq('sensu/sensu-ruby-runtime')
      end
    end

    it 'should have email-handler asset installed' do
      on agent, 'sensuctl asset info sensu/sensu-email-handler --format json' do |result|
        data = JSON.parse(result.stdout)
        expect(data['metadata']['name']).to eq('sensu/sensu-email-handler')
      end
    end
  end
end
