# Sensu-Puppet

Installs and manages the open source monitoring framework [Sensu](http://sensuapp.org).
[![Puppet Forge](http://img.shields.io/puppetforge/v/sensu/sensu.svg)](https://forge.puppetlabs.com/sensu/sensu)

## Tested with Travis CI

[![Build Status](https://travis-ci.org/sensu/sensu-puppet.png)](https://travis-ci.org/sensu/sensu-puppet)

## Documented with Puppet Strings

[Puppet Strings documentation](http://sensu.github.io/sensu-puppet/)

## Sensu version supported

The module currently supports Sensu version 0.12 and later. If not explictly stated it should always
support the latest Sensu release. Please log an issue if you identify any incompatibilties.

## Upgrade note

Versions prior to 1.0.0 are incompatible with previous versions of the
Sensu-Puppet module.

## Installation

    $ puppet module install sensu/sensu

## Prerequisites

- Redis server and connectivity to a Redis database
- RabbitMQ server, vhost, and credentials
- Ruby JSON library or gem

### Dependencies

- puppetlabs/apt
- puppetlabs/stdlib
- maestrodev/wget

See `metadata.json` for details.

Pluginsync should be enabled. Also, you will need the Ruby JSON library
or gem on all your nodes.

[EPEL](http://mirrors.kernel.org/fedora-epel/6/x86_64/rubygem-json-1.4.6-1.el6.x86_64.rpm)

Rubygem:

    $ sudo gem install json

Debian & Ubuntu:

    $ sudo apt-get install ruby-json

## Quick start

Before this puppet module can be used, the following items must be configured on the server.

- Install redis
- Install rabbitmq
- Add users to rabbitmq
- Install dashboard (optional)

To quickly try out sensu, spin up a test VM with Vagrant that already has these prerequisites installed.

    vagrant up
    vagrant status
    vagrant ssh sensu-server

You can then access the api

    curl http://admin:secret@localhost:4567/info


Navigate to `192.168.56.10:3000` to use the uchiwa dashboard

    username => uchiwa
    password => uchiwa

Navigate to `192.168.56.10:15672` to manage rabbitmq

    username => sensu
    password => correct-horse-battery-staple

See the [tests directory](https://github.com/sensu/sensu-puppet/tree/vagrant/tests) and [Vagrantfile](https://github.com/sensu/sensu-puppet/blob/vagrant/Vagrantfile) for examples on setting up the prerequisites.


## Basic example

### Sensu server

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


### Sensu client

    node 'sensu-client.foo.com' {
       class { 'sensu':
         rabbitmq_password  => 'correct-horse-battery-staple',
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
are managed with the server, and API parameters.

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

      ...

      sensu::check { "diskspace":
        command => '/etc/sensu/plugins/system/check-disk.rb',
      }


    }

### Sensu client

    node 'sensu-client.foo.com' {
       class { 'sensu':
         rabbitmq_password  => 'correct-horse-battery-staple',
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

## Extension configuration

    sensu::extension {
      'an_extension':
        source  => 'puppet://somewhere/an_extension.rb',
        config  => {
          'foobar_setting' => 'value',
      }
    }

This will save the extension under /etc/sensu/extensions and create
the following configuration definition for Sensu:

     {
       "an_extension": {
         "foobar_setting": "value"
       },
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

You can also define custom variables as part of the subscription:

ntp/manifests/monitoring/ntp.pp

    class ntp::monitoring::sensu {
      sensu::subscription { 'ntp':
        custom => {
          ntp {
            server => $ntp::servers[0],
          },
        },
      }
    }

And then use that variable on your Sensu server:

    sensu::check { 'check_ntp':
      command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H :::ntp.server::: -w 30 -c 60',
      ...
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

## Installing Gems into the embedded ruby

If you are using the embedded ruby that ships with sensu, you can install gems
by using the `sensu_gem` package provier:

    package { 'redphone':
      ensure   => 'installed',
      provider => sensu_gem,
    }

## Dashboards

The following puppet modules exist for managing dashboards

* [uchiwa](https://github.com/pauloconnor/pauloconnor-uchiwa)

## License

See LICENSE file.

