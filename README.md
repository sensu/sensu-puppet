# Sensu-Puppet

Tested with Travis CI

[![Build Status](https://travis-ci.org/sensu/sensu-puppet.png)](https://travis-ci.org/sensu/sensu-puppet)

## Upgrade note
Version 0.5.0 and later are incompatible with previous versions of the
Sensu-Puppet module.

## Installation

    $ puppet module install sensu/sensu

## Prerequisites
- Redis server and connectivity to a Redis database
- RabbitMQ server, vhost, and credentials

### Dependencies

- puppetlabs/apt

See Modulefile for details.

### Others

Pluginsync should be enabled. Also, you will need the Ruby JSON library
or gem on all your nodes.

[EPEL](http://mirrors.kernel.org/fedora-epel/6/x86_64/rubygem-json-1.4.6-1.el6.x86_64.rpm)

## Basic Example

### Sensu Server

    node 'sensu-server.foo.com' {
      class { 'sensu':
        rabbitmq_password => 'secret',
        server            => true,
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


### Sensu Client

    node 'sensu-client.foo.com' {
       class { 'sensu':
         rabbitmq_password  => 'secret',
         rabbitmq_host      => 'sensu-server.foo.com',
         subscriptions      => 'sensu-test',
       }
    }

## Advanced Example (hiera)
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
    sensu::install_repo: 'false'
    sensu::purge_config: true
    sensu::rabbitmq_host: 10.31.0.90
    sensu::rabbitmq_password: password
    sensu::rabbitmq_port: 5672

### sensu-server.foo.com.yaml

    sensu::server: true

nosensu.foo.com.yaml

    sensu::client: 'false'

site.pp

    node default {
      class { 'sensu': }
      ...
    }

## Safe Mode checks

By default Sensu clients will execute whatever check messages are on the
queue.  This is potentially a large security hole.
If you enable the safe_mode parameter, it will require that checks are
defined on the client.  If standalone checks are used then defining on
the client is sufficient, otherwise checks will also need to be defined
on the server as well.

A usage example is shown below.

### Sensu server

    node 'sensu-server.foo.com' {
      class { 'sensu':
        rabbitmq_password => 'secret',
        server            => true,
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
        refresh     => 1800,
        standalone  => true,
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

