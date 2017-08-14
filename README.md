# Sensu-Puppet

Installs and manages the open source monitoring framework [Sensu](http://sensuapp.org).
[![Puppet Forge](http://img.shields.io/puppetforge/v/sensu/sensu.svg)](https://forge.puppetlabs.com/sensu/sensu)

## Tested with Travis CI

[![Build Status](https://travis-ci.org/sensu/sensu-puppet.png)](https://travis-ci.org/sensu/sensu-puppet)

## Documented with Puppet Strings

[Puppet Strings documentation](http://sensu.github.io/sensu-puppet/doc/)

## Compatibility - supported sensu versions

If not explicitly stated it should always support the latest Sensu release.
Please log an issue if you identify any incompatibilities.

| Sensu Version    | Recommended Puppet Module Version   |
| ---------------- | ----------------------------------- |
| >= 0.26.0        | latest                              |
| 0.22.x - 0.25.x  | 2.1.0                               |
| 0.20.x - 0.21.x  | 2.0.0                               |
| 0.17.x - 0.19.x  | 1.5.5                               |


## Upgrade note

Versions prior to 1.0.0 are incompatible with previous versions of the
Sensu-Puppet module.

## Installation

```bash
puppet module install sensu/sensu
```

## Prerequisites

- Redis server and connectivity to a Redis database
- RabbitMQ server, vhost, and credentials
- Ruby JSON library or gem

### Dependencies

See `metadata.json` for details.

- puppetlabs/stdlib
- lwf/puppet-remote_file

Soft dependencies if you use the corresponding technologies.

- [puppetlabs/apt](https://github.com/puppetlabs/puppetlabs-apt)
- [puppetlabs/powershell](https://github.com/puppetlabs/puppetlabs-powershell)
- [voxpupuli/rabbitmq](https://github.com/voxpupuli/puppet-rabbitmq)

Note: While this module works with other versions of puppetlabs/apt, we
test against and support what is listed in the `.fixtures.yml` file.

Pluginsync should be enabled. Also, you will need the Ruby JSON library
or gem on all your nodes.

[EPEL](http://mirrors.kernel.org/fedora-epel/6/x86_64/rubygem-json-1.4.6-1.el6.x86_64.rpm)

Rubygem:

```bash
sudo gem install json
```

Debian & Ubuntu:

```bash
sudo apt-get install ruby-json
```

## Quick start

Before this Puppet module can be used, the following items must be configured on the server.

- Install Redis
- Install RabbitMQ
- Add users to RabbitMQ
- Install dashboard (optional)

To quickly try out Sensu, spin up a test virtual machine with Vagrant that already has these prerequisites installed.

```bash
vagrant up
vagrant status
vagrant ssh sensu-server
```

You can then access the API.

```bash
curl http://admin:secret@192.168.56.10:4567/info
```

Navigate to `192.168.56.10:3000` to use the uchiwa dashboard

```yaml
username: uchiwa
password: uchiwa
```

Navigate to `192.168.56.10:15672` to manage RabbitMQ

```yaml
username: sensu
password: correct-horse-battery-staple
```

See the [tests
directory](https://github.com/sensu/sensu-puppet/tree/master/tests) and
[Vagrantfile](https://github.com/sensu/sensu-puppet/blob/master/Vagrantfile)
for examples on setting up the prerequisites.

## Basic example

### Sensu server

```puppet
node 'sensu-server.foo.com' {
  class { 'sensu':
    rabbitmq_password => 'correct-horse-battery-staple',
    server            => true,
    api               => true,
    plugins           => [
      'puppet:///data/sensu/plugins/ntp.rb',
      'puppet:///data/sensu/plugins/postfix.rb'
    ]
  }

  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' ops@foo.com',
  }

  sensu::check { 'check_ntp':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    handlers    => 'default',
    subscribers => 'sensu-test'
  }

  sensu::check { '...':
    ...
  }
}
```

### Sensu Enterprise Server

With [Sensu Enterprise](https://sensuapp.org/enterprise) additional
functionality is available, for example [Contact
Routing](https://sensuapp.org/docs/0.29/enterprise/contact-routing.html)

An example configuring notification routing to specific groups:

```puppet
node 'sensu-server.foo.com' {

  file { 'api.keystore':
    ensure => 'file',
    path   => '/etc/sensu/api.keystore',
    source => 'puppet:///modules/sensu/test.api.keystore',
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0600',
  }

  # NOTE: When testing sensu enterprise, provide the SE_USER and SE_PASS to use
  # with the online repository using the FACTER_SE_USER and FACTER_SE_PASS
  # environment variables.
  class { '::sensu':
    install_repo              => true,
    enterprise                => true,
    enterprise_user           => $facts['se_user'],
    enterprise_pass           => $facts['se_pass'],
    manage_services           => true,
    manage_user               => true,
    purge_config              => true,
    rabbitmq_password         => 'correct-horse-battery-staple',
    rabbitmq_vhost            => '/sensu',
    client_address            => $::ipaddress_eth1,
    api_ssl_port              => '4568',
    api_ssl_keystore_file     => '/etc/sensu/api.keystore',
    api_ssl_keystore_password => 'sensutest',
  }

  sensu::contact { 'support':
    ensure => 'present',
    config => {
      'email' => {
        'to'   => 'support@example.com',
        'from' => 'sensu.noreply@example.com',
      },
      'slack' => {
        'channel' => '#support',
      },
    },
  }
  sensu::contact { 'ops':
    ensure => 'present',
    config => { 'email'  => { 'to' => 'ops@example.com' } },
  }
  # A second check to use the built-in email handler and contact.
  sensu::check { 'check_ntp':
    command     => 'PATH=$PATH:/usr/lib64/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    handlers    => 'email',
    contacts    => ['ops', 'support'],
    subscribers => 'sensu-test',
  }
}
```

### Sensu client

```puppet
node 'sensu-client.foo.com' {
   class { 'sensu':
     rabbitmq_password  => 'correct-horse-battery-staple',
     rabbitmq_host      => 'sensu-server.foo.com',
     subscriptions      => 'sensu-test',
   }
}
```

## Advanced example using Hiera

This example includes the `sensu` class as part of a base class or role
and configures Sensu on each individual node via
[Hiera](http://docs.puppetlabs.com/#hierahiera1).

### hiera.yaml

```yaml
---
:hierarchy:
  - %{fqdn}
  - %{datacenter}
  - common
:backends:
  - yaml
:yaml:
  :datadir: '/etc/puppet/%{environment}/modules/hieradata'
```

### common.yaml

```yaml
sensu::install_repo: false
sensu::purge:
  config: true
sensu::rabbitmq_host: 10.31.0.90
sensu::rabbitmq_password: password
sensu::rabbitmq_port: 5672
```

### sensu-server.foo.com.yaml

```yaml
sensu::server: true
```

nosensu.foo.com.yaml

```yaml
sensu::client: false
```

site.pp

```puppet
node default {
  class { 'sensu': }
  ...
}
```

### sensu-client.foo.com.yaml

```yaml
---
sensu::subscriptions:
    - all
sensu::server: false
sensu::extensions:
  'system':
    source: 'puppet:///modules/supervision/system_profile.rb'
sensu::handlers:
  'graphite':
    type: 'tcp'
    socket:
      host: '127.0.0.1'
      port: '2003'
    mutator: "only_check_output"
  'file':
    command: '/etc/sensu/handlers/file.rb'
  'mail':
    command: 'mail -s 'sensu event' email@address.com'
sensu::handler_defaults:
  type: 'pipe'
sensu::checks:
  'file_test':
    command: '/usr/local/bin/check_file_test.sh'
  'chef_client':
    command: 'check-chef-client.rb'
sensu::filters:
  'recurrences-30':
    attributes:
      occurrences: "eval: value == 1 || value % 30 == 0"
sensu::filter_defaults:
  negate: true
  when:
    days:
      all:
        - begin: 5:00 PM
          end: 8:00 AM
sensu::check_defaults:
  handlers: 'mail'
sensu::mutators:
  'tag':
    command: '/etc/sensu/mutators/tag.rb'
  'graphite':
    command: '/etc/sensu/plugins/graphite.rb'
classes:
    - sensu
```


## Safe Mode checks

By default Sensu clients will execute whatever check messages are on the
queue. This is potentially a large security hole.

If you enable the `safe_mode` parameter, it will require that checks are
defined on the client. If standalone checks are used then defining on
the client is sufficient, otherwise checks will also need to be defined
on the server as well.

A usage example is shown below.

### Sensu server

Each component of Sensu can be controlled separately. The server components
are managed with the server, and API parameters.

```puppet
node 'sensu-server.foo.com' {
  class { 'sensu':
    rabbitmq_password => 'correct-horse-battery-staple',
    server            => true,
    api               => true,
    plugins           => [
      'puppet:///data/sensu/plugins/ntp.rb',
      'puppet:///data/sensu/plugins/postfix.rb'
    ],
    safe_mode         => true,
  }

  # ...

  sensu::check { "diskspace":
    command => '/etc/sensu/plugins/system/check-disk.rb',
  }
}
```

If you need only one plugin you can also use a simple string:

```puppet
node 'sensu-server.foo.com' {
  class { 'sensu':
    plugins => 'puppet:///data/sensu/plugins/ntp.rb',
    # ...
  }
}
```

Specifying the plugins as hash, you can pass all parameters supported by
the sensu::plugin define:

```puppet
node 'sensu-server.foo.com' {
  class { 'sensu':
    plugins           => {
      'puppet:///data/sensu/plugins/ntp.rb' => {
        'install_path' => '/alternative/path',
      'puppet:///data/sensu/plugins/postfix.rb'
        'type'         => 'package',
        'pkg_version'  => '2.4.2',
    },
    ...
  }
}
```


### Sensu client

```puppet
node 'sensu-client.foo.com' {
  class { 'sensu':
    rabbitmq_password => 'correct-horse-battery-staple',
    rabbitmq_host     => 'sensu-server.foo.com',
    subscriptions     => 'sensu-test',
    safe_mode         => true,
  }

  sensu::check { 'diskspace':
    command => '/etc/sensu/plugins/system/check-disk.rb',
  }
}
```

## Using custom variables in check definitions

```puppet
sensu::check{ 'check_file_test':
  command      => '/usr/local/bin/check_file_test.sh',
  handlers     => 'notifu',
  custom       => {
    'foo'      => 'bar',
    'numval'   => 6,
    'boolval'  => true,
    'in_array' => ['foo','baz']
  },
  subscribers  => 'sensu-test'
}
```

This will create the following check definition for Sensu:

```json
{
  "checks": {
    "check_file_test": {
      "handlers": [
        "notifu"
      ],
      "in_array": [
        "foo",
        "baz"
      ],
      "command": "/usr/local/bin/check_file_test.sh",
      "subscribers": [
        "sensu-test"
      ],
      "foo": "bar",
      "interval": 60,
      "numval": 6,
      "boolval": true
    }
  }
}
```

## Writing custom configuration files

You can also use the `sensu::write_json` defined resource type to write custom
json config files:

```puppet
$contact_data = {
  'support' => {
    'pagerduty' => {
      'service_key' => 'r3FPuDvNOTEDyQYCc7trBkymIFcy2NkE',
    },
    'slack' => {
      'channel'  => '#support',
      'username' => 'sensu',
    }
  }
}

sensu::write_json { '/etc/sensu/conf.d/contacts.json':
  content => $contact_data,
}
```

## Handler configuration

```puppet
sensu::handler {
  'handler_foobar':
    command => '/etc/sensu/handlers/foobar.py',
    type    => 'pipe',
    config  => {
      'foobar_setting' => 'value',
  }
}
```

This will create the following handler definition for Sensu (server):

```json
{
  "handler_foobar": {
    "foobar_setting": "value"
  },
  "handlers": {
     "handler_foobar": {
       "command": "/etc/sensu/plugins/foobar.py",
       "severities": [
         "ok",
         "warning",
         "critical",
         "unknown"
       ],
     "type": "pipe"
    }
  }
}
```

## Extension configuration

```puppet
sensu::extension {
  'an_extension':
    source  => 'puppet://somewhere/an_extension.rb',
    config  => {
      'foobar_setting' => 'value',
  }
}
```

This will save the extension under /etc/sensu/extensions and create
the following configuration definition for Sensu:

```json
{
  "an_extension": {
    "foobar_setting": "value"
  },
}
```

### Disable Service Management

If you'd prefer to use an external service management tool such as
DaemonTools or SupervisorD, you can disable the module's internal
service management functions like so:

```yaml
sensu::manage_services: false
```

## Purging Configuration

By default, any sensu plugins, extensions, handlers, mutators, and
configuration not defined using this puppet module will be left on
the filesystem. This can be changed using the `purge` parameter.

If all sensu plugins, extensions, handlers, mutators, and configuration
should be managed by puppet, set the `purge` parameter to `true` to
delete files which are not defined using this puppet module:

```yaml
sensu::purge: true
```

To get more fine-grained control over what is purged, set the `purge`
parameter to a hash. The possible keys are: `config`, `plugins`,
`extensions`, `handlers`, `mutators`. Any key whose value is `true`
cause files of that type which are not defined using this puppet module
to be deleted. Keys which are not specified will not be purged:

```yaml
sensu::purge:
  config: true
  plugins: true
```

## Including Sensu monitoring in other modules

There are a few different patterns that can be used to include Sensu
monitoring into other modules. One pattern creates a new class that is
included as part of the host or node definition and includes a
standalone check, for example:

apache/manifests/monitoring/sensu.pp

```puppet
class apache::monitoring::sensu {
  sensu::check { 'apache-running':
    handlers    => 'default',
    command     => '/etc/sensu/plugins/check-procs.rb -p /usr/sbin/httpd -w 100 -c 200 -C 1',
    custom      => {
      refresh     => 1800,
      occurrences => 2,
    },
  }
}
```

You could also include subscription information and let the Sensu server
schedule checks for this service as a subscriber:

apache/manifests/monitoring/sensu.pp

```puppet
class apache::monitoring::sensu {
  sensu::subscription { 'apache': }
}
```

You can also define custom variables as part of the subscription:

ntp/manifests/monitoring/ntp.pp

```puppet
class ntp::monitoring::sensu {
  sensu::subscription { 'ntp':
    custom => {
      ntp {
        server => $ntp::servers[0],
      },
    },
  }
}
```

And then use that variable on your Sensu server:

```puppet
sensu::check { 'check_ntp':
  command => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H :::ntp.server::: -w 30 -c 60',
  # ...
}
```

If you would like to automatically include the Sensu monitoring class as
part of your existing module with the ability to support different
monitoring platforms, you could do something like:

apache/manifests/service.pp

```puppet
$monitoring = hiera('monitoring', '')

case $monitoring {
  'sensu':  { include apache::monitoring::sensu }
  'nagios': { include apache::monitoring::nagios }
}
```

## Installing Gems into the embedded ruby

If you are using the embedded ruby that ships with Sensu, you can install gems
by using the `sensu_gem` package provider:

```puppet
package { 'redphone':
  ensure   => 'installed',
  provider => sensu_gem,
}
```

## Sensitive String Redaction

Redaction of passwords is supported by this module. To enable it, pass a value to `sensu::redact`
and set some password values with `sensu::client_custom`

```puppet
class { 'sensu':
  redact  => 'password',
  client_custom => {
    github => {
      password => 'correct-horse-battery-staple',
    },
  },
}
```

Or with hiera:

```yaml
sensu::redact:
  - :password"
sensu::client_custom:
  - sensu::client_custom:
  nexus:
    password: "correct-horse-battery-staple'
```

This ends up like this in the uchiwa console:

![Sensu Redaction](http://i.imgur.com/K4noGoN.png)

You can make use of the password now when defining a check by using command substitution:

```puppet
sensu::check { 'check_password_test':
  command => '/usr/local/bin/check_password_test --password :::github.password::: ',
}
```


## Dashboards

### Sensu Enterprise Dashboard

The [Sensu Enterprise
Dashboard](https://sensuapp.org/docs/latest/platforms/sensu-on-rhel-centos.html#install-sensu-enterprise-repository)
is fully managed by this module.  Credentials for the repository are required to
automatically install packages and configure the enterprise dashboard.  For
example:

```puppet
class { '::sensu':
  enterprise_dashboard => true,
  enterprise_user      => '1234567890',
  enterprise_pass      => 'PASSWORD',
}
```

The `enterprise_user` and `enterprise_pass` class parameters map to the
`SE_USER` and `SE_PASS` as described at [Install the Sensu Enterprise repository
](https://sensuapp.org/docs/latest/platforms/sensu-on-rhel-centos.html#install-sensu-enterprise-repository)

### Enterprise Dashboard API

The API to the enterprise dashboard is managed using the
`sensu::enterprise::dashboard::api` defined type.  This defined type is a
wrapper around the `sensu_enterprise_dashboard_api_config` custom type and
provider included in this module.

These Puppet resource types manage the Dashboard API entries in
`/etc/sensu/dashboard.json`.

Multiple API endpoints may be defined in the same datacenter.  This example will
create two endpoints at sensu.example.net and sensu.example.org.

```puppet
sensu::enterprise::dashboard::api { 'sensu.example.net':
  datacenter => 'example-dc',
}

sensu::enterprise::dashboard::api { 'sensu.example.org':
  datacenter => 'example-dc',
}
```

Unmanaged API endpoints may be purged using the resources resource.  For
example:

```puppet
resources { 'sensu_enterprise_dashboard_api_config':
  purge => true,
}
```

This will ensure `/etc/sensu/dashboard.json` contains only
`sensu::enterprise::dashboard::api` resources managed by Puppet.

### Community

The following puppet modules exist for managing dashboards

* [uchiwa](https://github.com/pauloconnor/pauloconnor-uchiwa)

## License

See LICENSE file.
