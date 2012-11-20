# Sensu-Puppet

This module is basically functional.

## Installation

$ puppet module install sensu/sensu

## Prerequisites

### Modules

- puppetlabs/apt
- puppetlabs/rabbitmq
- thomasvandoren/redis

See Modulefile for details.

### Others

Pluginsync should be enabled. Also, you need ruby json library/gem on all your nodes.  

## Example
    
### Sensu Server

    node "sensu-server.foo.com" { 
      sensu::server { "${::fqdn}-sensu-server": rabbitmq_password => "secret" }

      sensu::check { "check_ntp": 
        command => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
        handlers => "default",
        subscribers => "sensu-test"
      }

      sensu::check { "...": 
        ...
      }
    }
    

### Sensu Client
    
    node "sensu-client.foo.com" { 
       sensu::client { "$::fqdn":
         rabbitmq_password => "secret",
         rabbitmq_host => "sensu-server.foo.com",
         subscriptions => "sensu-test"
       }
    }

## License

MIT

