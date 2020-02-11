# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/contact-routing/

include sensu::backend

sensu_bonsai_asset { 'sensu/sensu-go-has-contact-filter':
  ensure  => 'present',
  version => 'latest',
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
  version => 'latest',
}

sensu_handler { 'email_dev':
  ensure         => 'present',
  type           => 'pipe',
  command        => 'sensu-email-handler -f root@localhost -t dev@example.com -s localhost -i',
  timeout        => 10,
  runtime_assets => ['sensu/sensu-email-handler'],
  filters        => ['is_incident','not_silenced','contact_dev'],
}
sensu_handler { 'email_ops':
  ensure         => 'present',
  type           => 'pipe',
  command        => 'sensu-email-handler -f root@localhost -t ops@example.com -s localhost -i',
  timeout        => 10,
  runtime_assets => ['sensu/sensu-email-handler'],
  filters        => ['is_incident','not_silenced','contact_ops'],
}
sensu_handler { 'email':
  ensure   => 'present',
  type     => 'set',
  handlers => ['email_dev','email_ops'],
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
