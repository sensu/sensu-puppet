#!/bin/bash

# Rabbitmq needs to have a user that sensu can connect to. 
# The default user of 'guest' can only connect over localhost http://bit.ly/1thfSKL

/usr/sbin/rabbitmqctl add_vhost /sensu
/usr/sbin/rabbitmqctl add_user sensu correct-horse-battery-staple
/usr/sbin/rabbitmqctl set_user_tags sensu administrator
/usr/sbin/rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"


# If you can't log into the web portal, you may need to reset the password
# /usr/sbin/rabbitmqctl change_password sensu correct-horse-battery-staple