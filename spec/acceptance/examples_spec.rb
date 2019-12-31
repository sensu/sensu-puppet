require 'spec_helper_acceptance'

describe 'contact routing', if: RSpec.configuration.sensu_full do
  node = hosts_as('sensu_backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
include sensu::backend
sensu_bonsai_asset { 'sensu/sensu-go-has-contact-filter':
  ensure  => 'present',
  version => '0.2.0',
}
sensu_filter { 'contact_dev':
  ensure         => 'present',
  action         => 'allow',
  runtime_assets => ['sensu/sensu-go-has-contact-filter'],
  expressions    => ['has_contact(event, "dev")'],
}
sensu_filter { 'contact_ops':
  ensure         => 'present',
  action         => 'allow',
  runtime_assets => ['sensu/sensu-go-has-contact-filter'],
  expressions    => ['has_contact(event, "ops")'],
}
sensu_bonsai_asset { 'sensu/sensu-email-handler':
  ensure  => 'present',
  version => '0.2.0',
}
sensu_handler { 'email_dev':
  ensure          => 'present',
  type            => 'pipe',
  command         => 'sensu-email-handler -f root@localhost -t dev@example.com -s localhost -i',
  timeout         => 10,
  runtime_assets  => ['sensu/sensu-email-handler'],
  filters         => ['is_incident','not_silenced','contact_dev'],
}
sensu_handler { 'email_ops':
  ensure          => 'present',
  type            => 'pipe',
  command         => 'sensu-email-handler -f root@localhost -t ops@example.com -s localhost -i',
  timeout         => 10,
  runtime_assets  => ['sensu/sensu-email-handler'],
  filters         => ['is_incident','not_silenced','contact_ops'],
}
sensu_handler { 'email':
  ensure    => 'present',
  type      => 'set',
  handlers  => ['email_dev','email_ops'],
}
sensu_check { 'check_cpu':
  ensure         => 'present',
  labels         => {
    'contacts' => 'dev, ops',
  },
  command        => 'check-cpu.rb -w 75 -c 90',
  handlers       => ['email'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu-plugins-cpu-checks','sensu-ruby-runtime'],
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
  end
end
