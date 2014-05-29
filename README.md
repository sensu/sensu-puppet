# Sensu-Puppet

Tested with Travis CI

[![Build Status](https://travis-ci.org/sensu/sensu-puppet.png)](https://travis-ci.org/sensu/sensu-puppet)

## Upgrade note
Versions prior to 1.0.0 are incompatible with previous versions of the
Sensu-Puppet module.

## Installation

    $ puppet module install sensu/sensu

## Prerequisites
- Redis server and connectivity to a Redis database
- RabbitMQ server, vhost, and credentials

### Dependencies
- puppetlabs/apt
- puppetlabs/stdlib

See `Modulefile` for details.

Pluginsync should be enabled. Also, you will need the Ruby JSON library
or gem on all your nodes.

[EPEL](http://mirrors.kernel.org/fedora-epel/6/x86_64/rubygem-json-1.4.6-1.el6.x86_64.rpm)

Rubygem:

    $ sudo gem install json

Debian & Ubuntu:

    $ sudo apt-get install ruby-json

## Basic example

### Sensu server

    node 'sensu-server.foo.com' {
      class { 'sensu':
        rabbitmq_password => 'secret',
        server            => true,
        dashboard         => true,
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


### Sensu client

    node 'sensu-client.foo.com' {
       class { 'sensu':
         rabbitmq_password  => 'secret',
         rabbitmq_host      => 'sensu-server.foo.com',
         subscriptions      => 'sensu-test',
       }
    }

## Advanced example using Hiera

This example includes the `sensu` class as part of a base class or role
and configures Sensu on each individual node via
[Hiera](http://docs.puppetlabs.com/#hierahiera1).

### hiera.yaml

    ---
    :hierarchy:
      - %{fqdn}
      - %{datacenter}
      - common
    :backends:
      - yaml
    :yaml:
      :datadir: '/etc/puppet/%{environment}/modules/hieradata'

### common.yaml

    sensu::dashboard_port: 8090
    sensu::dashboard_password: mysupersecretpassword
    sensu::install_repo: false
    sensu::purge_config: true
    sensu::rabbitmq_host: 10.31.0.90
    sensu::rabbitmq_password: password
    sensu::rabbitmq_port: 5672

### sensu-server.foo.com.yaml

    sensu::server: true

nosensu.foo.com.yaml

    sensu::client: false

site.pp

    node default {
      class { 'sensu': }
      ...
    }

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
are managed with the server, dashboard, and API parameters.

    node 'sensu-server.foo.com' {
      class { 'sensu':
        rabbitmq_password => 'secret',
        server            => true,
        dashboard         => true,
        api               => true,
        plugins           => [
          'puppet:///data/sensu/plugins/ntp.rb',
          'puppet:///data/sensu/plugins/postfix.rb'
        ],
        safe_mode         => true,
      }

      ...

      sensu::check { "diskspace":
        command => '/etc/sensu/plugins/system/check-disk.rb',
      }


    }

### Sensu client

    node 'sensu-client.foo.com' {
       class { 'sensu':
         rabbitmq_password  => 'secret',
         rabbitmq_host      => 'sensu-server.foo.com',
         subscriptions      => 'sensu-test',
         safe_mode          => true,
       }

      sensu::check { "diskspace":
        command => '/etc/sensu/plugins/system/check-disk.rb',
      }
    }


## Using custom variables in check definitions

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

This will create the following check definition for Sensu:

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

## Handler configuration

    sensu::handler {
      'handler_foobar':
        command => '/etc/sensu/handlers/foobar.py',
        type    => 'pipe',
        config  => {
          'foobar_setting' => 'value',
      }
    }

This will create the following handler definition for Sensu (server):

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

### Disable Service Management

If you'd prefer to use an external service management tool such as
DaemonTools or SupervisorD, you can disable the module's internal
service management functions like so:

    sensu::manage_services: false


## Including Sensu monitoring in other modules

There are a few different patterns that can be used to include Sensu
monitoring into other modules. One pattern creates a new class that is
included as part of the host or node definition and includes a
standalone check, for example:

apache/manifests/monitoring/sensu.pp

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

You could also include subscription information and let the Sensu server
schedule checks for this service as a subscriber:

apache/manifests/monitoring/sensu.pp

    class apache::monitoring::sensu {
      sensu::subscription { 'apache': }
    }

If you would like to automatically include the Sensu monitoring class as
part of your existing module with the ability to support different
monitoring platforms, you could do something like:

apache/manifests/service.pp

    $monitoring = hiera('monitoring', '')

    case $monitoring {
      'sensu':  { include apache::monitoring::sensu }
      'nagios': { include apache::monitoring::nagios }
    }


## License

See LICENSE file.

