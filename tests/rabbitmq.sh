#!/bin/bash

# Create permissions for sensu user and vhost for /sensu
# Set policy for results and keepalives queues to ha-mode

/usr/sbin/rabbitmqctl add_vhost /sensu
/usr/sbin/rabbitmqctl set_user_tags sensu administrator
/usr/sbin/rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"
/usr/sbin/rabbitmqctl set_policy ha-sensu "^(results$|keepalives$)" '{"ha-mode":"all", "ha-sync-mode":"automatic"}' -p /sensu




# If you can't log into the web portal, you may need to reset the password
# which should have been set through the puppet module.

# /usr/sbin/rabbitmqctl change_password sensu correct-horse-battery-staple
