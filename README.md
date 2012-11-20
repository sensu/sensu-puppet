This module is still under heavy development.

Prerequisites
=============
Pluginsync should be enabled. Also, you need ruby json library/gem on all your nodes.  


Example
=======
    
    # server
    node "sensu-server.foo.com" { 
      sensu::server { "$::fqdn-sensu-server": rabbitmq_password => "secret" }

      sensu::check { "check_ntp": 
        command => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
        handlers => "default",
        subscribers => "sensu-test"
      }

      sensu::check { "...": 
        ...
      }
    }
    
    # client 
    node "sensu-client.foo.com" { 
       sensu::client { "$::fqdn":
         rabbitmq_password => "secret",
         rabbitmq_host => "sensu-server.foo.com",
         subscriptions => "sensu-test"
       }
    }





 




