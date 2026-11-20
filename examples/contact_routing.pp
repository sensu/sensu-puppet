# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/contact-routing/
# Prerequisites: sensu-puppet module, puppetlabs/stdlib

class { 'sensu':
  use_ssl => false,
}

include sensu::backend
include sensu::cli

exec { 'add sensu-go-has-contact-filter asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/sensu-go-has-contact-filter',
  unless  => 'sensuctl asset info sensu/sensu-go-has-contact-filter',
  require => Sensuctl_configure['puppet'],
}

exec { 'add sensu-email-handler asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/sensu-email-handler',
  unless  => 'sensuctl asset info sensu/sensu-email-handler',
  require => Sensuctl_configure['puppet'],
}

exec { 'add check-cpu-usage asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/check-cpu-usage',
  unless  => 'sensuctl asset info sensu/check-cpu-usage',
  require => Sensuctl_configure['puppet'],
}

sensu_filter { 'contact_dev':
  ensure         => 'present',
  action         => 'allow',
  runtime_assets => ['sensu/sensu-go-has-contact-filter'],
  expressions    => ['has_contact(event, "dev")'],
  require        => Exec['add sensu-go-has-contact-filter asset'],
}

sensu_filter { 'contact_ops':
  ensure         => 'present',
  action         => 'allow',
  runtime_assets => ['sensu/sensu-go-has-contact-filter'],
  expressions    => ['has_contact(event, "ops")'],
  require        => Exec['add sensu-go-has-contact-filter asset'],
}

sensu_handler { 'email_dev':
  ensure         => 'present',
  type           => 'pipe',
  command        => 'sensu-email-handler -f root@localhost -t dev@example.com -s localhost -i',
  timeout        => 10,
  runtime_assets => ['sensu/sensu-email-handler'],
  filters        => ['is_incident', 'not_silenced', 'contact_dev'],
  require        => Exec['add sensu-email-handler asset'],
}

sensu_handler { 'email_ops':
  ensure         => 'present',
  type           => 'pipe',
  command        => 'sensu-email-handler -f root@localhost -t ops@example.com -s localhost -i',
  timeout        => 10,
  runtime_assets => ['sensu/sensu-email-handler'],
  filters        => ['is_incident', 'not_silenced', 'contact_ops'],
  require        => Exec['add sensu-email-handler asset'],
}

sensu_handler { 'email':
  ensure   => 'present',
  type     => 'set',
  handlers => ['email_dev', 'email_ops'],
}

sensu_check { 'check_cpu':
  ensure         => 'present',
  labels         => {
    'contacts' => 'dev, ops',
  },
  command        => 'check-cpu-usage -w 75 -c 90',
  handlers       => ['email'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu/check-cpu-usage'],
  require        => Exec['add check-cpu-usage asset'],
}
