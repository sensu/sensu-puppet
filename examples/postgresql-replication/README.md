The following directory contains examples of setting up a PostgreSQL primary/standby cluster that is used for Sensu Go backend events.

The example `sensu-backend.pp` will be applied to the Sensu Go backend.

The example `postgresql.pp` will be applied to both the primary and standby PostgreSQL servers.

Adjustments will have to be made for IP addresses and password.

Once the primary and standby have applied their Puppet catalog you must bootstrap the standby:

```
systemctl stop postgresql-9.6.service
rm -rf /var/lib/pgsql/9.6/data/*
sudo -u postgres pg_basebackup -h 192.168.52.11 -D /var/lib/pgsql/9.6/data -P -U repl -R --xlog-method=stream
```

Once the bootstrap is done, re-run Puppet.

Example command of checking that replicaton on the standby is functioning, run this command from the standby host:

```
PGPASSWORD='sensu' psql -U sensu -h localhost -c 'select * from events order by id desc LIMIT 1;'
```

Example command of checking primary replication:

```
PGPASSWORD='password' psql -U postgres -c "select pg_current_xlog_location()" -h localhost
```

Check the standby location matches primary

```
PGPASSWORD='password' psql -U postgres -c "select pg_last_xlog_receive_location()" -h localhost
PGPASSWORD='password' psql -U postgres -c "select pg_last_xlog_replay_location()" -h localhost
```
