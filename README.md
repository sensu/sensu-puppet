# Sensu-Puppet

#### Table of Contents

1. [Module Description](#module-description)
    * [Deprecations](#deprecations)
2. [Setup - The basics of getting started with sensu](#setup)
    * [What sensu affects](#what-sensu-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sensu](#beginning-with-sensu)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Basic Sensu backend](#basic-sensu-backend)
    * [Basic Sensu agent](#basic-sensu-agent)
    * [Basic Sensu CLI](#basic-sensu-cli)
    * [Manage Windows Agent](#manage-windows-agent)
    * [Advanced agent](#advanced-agent)
    * [Advanced SSL](#advanced-ssl)
    * [Enterprise support](#enterprise-support)
    * [PostgreSQL datastore support](#postgresql-datastore-support)
    * [Installing Plugins](#installing-plugins)
    * [Installing Extensions](#installing-extensions)
    * [Exported resources](#exported-resources)
    * [Hiera resources](#hiera-resources)
    * [Resource purging](#resource-purging)
    * [Sensu backend cluster](#sensu-backend-cluster)
        * [Adding backend members to an existing cluster](#adding-backend-members-to-an-existing-cluster)
    * [Sensu backend federation](#sensu-backend-federation)
    * [Large Environment Considerations](#large-environment-considerations)
    * [Composite Names for Namespaces](#composite-names-for-namespaces)
    * [Installing Bonsai Assets](#installing-bonsai-assets)
    * [Bolt Tasks](#bolt-tasks)
4. [Reference](#reference)
    * [Facts](#facts)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [License](#license)

## Module description

Installs and manages [Sensu](http://sensuapp.org), the open source monitoring framework.

Please note, that this is a **Partner Supported** module, which means that technical customer support for this module is solely provided by Sensu. Puppet does not provide support for any **Partner Supported** modules. Technical support for this module is provided by Sensu at [https://sensuapp.org/support](https://sensuapp.org/support).

### Documented with Puppet Strings

[Puppet Strings documentation](http://sensu.github.io/sensu-puppet/)

### Compatibility - supported sensu versions

If not explicitly stated it should always support the latest Sensu release.
Please log an issue if you identify any incompatibilities.

| Sensu Go Version   | Recommended Puppet Module Version   |
| --------------- | ----------------------------------- |
| 5.x             | latest v3 |

### Upgrade note

Sensu Go 5.x is a rewrite of Sensu and no longer depends on redis and rabbitmq. Version 3 of this module supports Sensu Go 5.x.

Users wishing to use the old v2 Puppet module to support previous Ruby based Sensu should use [sensu/sensuclassic](https://forge.puppet.com/sensu/sensuclassic).

### Deprecations

#### sensu\_asset

The `url`, `sha512`, `filters` and `headers` properties for `sensu_asset` are deprecated in favor of passing these values as part of `builds` property.
Using these deprecated properties will still work but issue a warning when the Puppet catalog is applied.

Before:

```puppet
sensu_asset { 'test':
  ensure  => 'present',
  url     => 'http://example.com/asset/example.tar',
  sha512  => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
  filters  => ["entity.system.os == 'linux'"],
}
```

After:
```puppet
sensu_asset { 'test':
  ensure => 'present',
  builds => [
    {
      'url'     => 'http://example.com/asset/example.tar',
      'sha512'  => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
      'filters' => ["entity.system.os == 'linux'"],
    },
  ],
}
```

## Setup

### What sensu effects

This module will install packages, create configuration and start services necessary to manage Sensu agents and backend.

### Setup requirements

Plugin sync is required if the custom sensu types and providers are used.

#### Soft module dependencies

For systems using `apt`:
  * [puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt) module (`>= 5.0.1 < 8.0.0`)

For systems using `yum` and Puppet >= 6.0.0:
  * [puppetlabs/yumrepo_core](https://forge.puppet.com/puppetlabs/yumrepo_core) module (`>= 1.0.1 < 2.0.0`)

For Windows:
  * [puppetlabs/chocolatey](https://forge.puppet.com/puppetlabs/chocolatey) module (`>= 3.0.0 < 5.0.0`)
  * [puppet/windows_env](https://forge.puppet.com/puppet/windows_env) module (`>= 3.0.0 < 4.0.0`)
  * [puppet/archive](https://forge.puppet.com/puppet/archive) module (`>= 3.0.    0 < 5.0.0`)

For PostgreSQL datastore support:
* [puppetlabs/postgresql](https://forge.puppet.com/puppetlabs/postgresql) module (`>= 6.0.0 < 7.0.0`)

### Beginning with sensu

This module provides Vagrant definitions that can be used to get started with Sensu.

```bash
vagrant up sensu-backend
vagrant ssh sensu-backend
```

#### Beginning with a Sensu cluster

Multiple Vagrant boxes are available for testing a sensu-backend cluster.

```bash
vagrant up sensu-backend-peer1 sensu-backend-peer2
vagrant provision sensu-backend-peer1 sensu-backend-peer2
```

#### Beginning with a Sensu federated cluster

Multiple Vagrant boxes are available for testing a Sensu Go federated cluster.
First build and provision both then provision the first a second time to view that the custom role was replicated.

```base
vagrant up sensu-backend-federated1 sensu-backend-federated2
vagrant provision sensu-backend-federated1
```

The `provision` command should output from `sensuctl` the `test` Sensu Go Role that was created on the other backend.
The output should look like the following:

```
    sensu-backend-federated1:   Name   Namespace   Rules  
    sensu-backend-federated1:  ────── ─────────── ─────── 
    sensu-backend-federated1:   test   default         1  
```

## Usage

### Basic Sensu backend

The following example will configure sensu-backend, sensu-agent on backend and add a check.
By default this module will configure the backend to use Puppet's SSL certificate and CA.
It's advisable to not rely on the default password. Changing the password requires providing the previous password via `old_password`.

```puppet
  class { 'sensu':
    password     => 'supersecret',
    old_password => 'P@ssw0rd!',
  }
  include sensu::backend
  include sensu::agent
  sensu_check { 'check-cpu':
    ensure        => 'present',
    command       => 'check-cpu.sh -w 75 -c 90',
    interval      => 60,
    subscriptions => ['linux'],
  }
```

### Basic Sensu agent

The following example will manage resources necessary to configure a sensu-agent to communicate with a sensu-backend and
associated to `linux` and `apache-servers` subscriptions.

```puppet
  class { 'sensu::agent':
    backends      => ['sensu-backend.example.com:8081'],
    subscriptions => ['linux', 'apache-servers'],
  }
```

### Basic Sensu CLI

The following example will manage the resources necessary to use `sensuctl`.

```puppet
class { '::sensu':
  api_host => 'sensu-backend.example.com',
  password => 'supersecret',
}
include ::sensu::cli
```

**NOTE**: The `sensu::backend` class calls the `sensu::cli` class so it is only necessary to directly call the `sensu::cli` class on hosts not using the `sensu::backend` class.

For Windows the `install_source` parameter must be provided:

```puppet
class { '::sensu':
  api_host => 'sensu-backend.example.com',
  password => 'supersecret',
}
class { '::sensu::cli':
  install_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.14.1/sensu-go_5.14.1_windows_amd64.zip',
}
```

### Manage Windows Agent

This module supports Windows Sensu Go agent via chocolatey beginning with version 5.12.0.

```puppet
class { 'sensu::agent':
  backends      => ['sensu-backend.example.com:8081'],
  subscriptions => ['windows'],
}
```

If you do not wish to install using chocolatey then you must define `package_source` as either a URL, a Puppet source or a filesystem path.

Install sensu-go-agent on Windows from URL:

```puppet
class { 'sensu::agent':
  package_name   => 'Sensu Agent',
  package_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.13.1/sensu-go-agent_5.13.1.5957_en-US.x64.msi',
}
```

Install sensu-go-agent on Windows from Puppet source:

```puppet
class { 'sensu::agent':
  package_name   => 'Sensu Agent',
  package_source => 'puppet:///modules/profile/sensu/sensu-go-agent.msi',
}
```

If a system already has the necessary MSI present it can be installed without downloading from an URL:

```puppet
class { 'sensu::agent':
  package_name   => 'Sensu Agent',
  package_source => 'C:\Temp\sensu-go-agent.msi',
}
```

### Advanced agent

If you wish to change the `agent` password you must provide the new and old password.
It's advisable to set `show_diff` to `false` to avoid exposing the agent password.

```puppet
class { 'sensu::backend':
  agent_password     => 'supersecret',
  agent_old_password => 'P@ssw0rd!',
}
class { 'sensu::agent':
  config_hash => {
    'password' => 'supersecret',
  },
  show_diff   => false,
}
```

### Advanced SSL

By default this module uses Puppet's SSL certificates and CA.
If you would prefer to use different certificates override the `ssl_ca_source`, `ssl_cert_source` and `ssl_key_source` parameters.
The value for `api_host` must be valid for the provided certificate and the value used for agent's `backends` must also match the certificate used by the specified backend.
If the certificates and keys are already installed then define the source parameters as filesystem paths.

```puppet
class { 'sensu':
  ssl_ca_source => 'puppet:///modules/profile/sensu/ca.pem',
  api_host      => 'sensu-backend.example.com',
}
class { 'sensu::backend':
  ssl_cert_source => 'puppet:///modules/profile/sensu/cert.pem',
  ssl_key_source  => 'puppet:///modules/profile/sensu/key.pem',
}
```
```puppet
class { 'sensu':
  ssl_ca_source => 'puppet:///modules/profile/sensu/ca.pem',
}
class { 'sensu::agent':
  backends      => ['sensu-backend.example.com:8081'],
  subscriptions => ['linux', 'apache-servers'],
}
```

To disable SSL support:

```puppet
class { 'sensu':
  use_ssl => false,
}
```

### Enterprise Support

In order to activate enterprise support the license file needs to be added:

```puppet
class { 'sensu::backend':
  license_source => 'puppet:///modules/profile/sensu/license.json',
}
```

The types `sensu_ad_auth` and `sensu_ldap_auth` require a valid enterprise license.

### PostgreSQL datastore support

**NOTE**: This features require a valid Sensu Go enterprise license.

The following example will add a PostgreSQL server and database to the sensu-backend host and configure Sensu Go to use PostgreSQL as the event datastore.

```puppet
class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '9.6',
}
class { 'postgresql::server': }
class { '::sensu::backend':
  license_source      => 'puppet:///modules/profile/sensu/license.json',
  datastore           => 'postgresql',
  postgresql_password => 'secret',
}
```

Refer to the [puppetlabs/postgresql](https://forge.puppet.com/puppetlabs/postgresql) module documentation for details on how to manage PostgreSQL with Puppet.

The following example uses an external PostgreSQL server.

```puppet
class { '::sensu::backend':
  license_source       => 'puppet:///modules/profile/sensu/license.json',
  datastore            => 'postgresql',
  postgresql_password  => 'secret',
  postgresql_host      => 'postgresql.example.com',
  manage_postgresql_db => false,
}
```

### Installing Plugins

Plugin management is handled by the `sensu::plugins` class.

Example installing plugins on agent:

```puppet
  class { 'sensu::agent':
    backends      => ['sensu-backend.example.com:8081'],
    subscriptions => ['linux', 'apache-servers'],
  }
  class { 'sensu::plugins':
    plugins => ['disk-checks'],
  }
```

The `plugins` parameter can also be a Hash that sets the version:

```puppet
  class { 'sensu::agent':
    backends      => ['sensu-backend.example.com:8081'],
    subscriptions => ['linux', 'apache-servers'],
  }
  class { 'sensu::plugins':
    plugins => {
      'disk-checks' => { 'version' => 'latest' },
    },
  }
```

Set `dependencies` to an empty Array to disable the `sensu::plugins` dependency management.

```puppet
  class { 'sensu::plugins':
    dependencies => [],
  }
```

If gems are required and not pulled in as gem dependencies they can also be installed.

```puppet
class { 'sensu::plugins':
  plugins          => ['memory-checks'],
  gem_dependencies => ['vmstat'],
}
```

You can uninstall plugins by passing `ensure` as `absent`.

```puppet
  class { 'sensu::agent':
    backends      => ['sensu-backend.example.com:8081'],
    subscriptions => ['linux', 'apache-servers'],
  }
  class { 'sensu::plugins':
    plugins => {
      'disk-checks' => { 'ensure' => 'absent' },
    },
  }
```

### Installing Extensions

Extension management is handled by the `sensu::plugins` class.

Example installing extension on backend:

```puppet
  class { 'sensu':
    password     => 'supersecret',
    old_password => 'P@ssw0rd!',
  }
  include sensu::backend
  class { 'sensu::plugins':
    extensions => ['graphite'],
  }
```

The `extensions` parameter can also be a Hash that sets the version:

```puppet
  class { 'sensu':
    password     => 'supersecret',
    old_password => 'P@ssw0rd!',
  }
  include sensu::backend
  class { 'sensu::plugins':
    extensions => {
      'graphite' => { 'version' => 'latest' },
    },
  }
```

You can uninstall extensions by passing `ensure` as `absent`.

```puppet
  class { 'sensu':
    password     => 'supersecret',
    old_password => 'P@ssw0rd!',
  }
  include sensu::backend
  class { 'sensu::plugins':
    extensions => {
      'graphite' => { 'ensure' => 'absent' },
    },
  }
```

### Exported resources

One possible approach to defining checks is having agents export their checks to the sensu-backend using [Exported Resources](https://puppet.com/docs/puppet/latest/lang_exported.html).

The following example would be defined for agents:

```puppet
  @@sensu_check { 'check-cpu':
    ensure        => 'present',
    command       => 'check-cpu.sh -w 75 -c 90',
    interval      => 60,
    subscriptions => ['linux'],
  }
```

The backend system would collect all `sensu_check` resources.

```puppet
  Sensu_check <<||>>
```

### Hiera resources

All the types provided by this module can have their resources defined via Hiera. A type such as `sensu_check` would be defined via `sensu::backend::checks`.

The following example adds an asset, filter, handler and checks via Hiera:

```yaml
sensu::backend::assets:
  sensu-email-handler:
    ensure: present
    url: 'https://github.com/sensu/sensu-email-handler/releases/download/0.1.0/sensu-email-handler_0.1.0_linux_amd64.tar.gz'
    sha512: '755c7a673d94997ab9613ec5969666e808f8b4a8eec1ba998ee7071606c96946ca2947de5189b24ac34a962713d156619453ff7ea43c95dae62bf0fcbe766f2e'
    filters:
      - "entity.system.os == 'linux'"
      - "entity.system.arch == 'amd64'"
sensu::backend::filters:
  hourly:
    ensure: present
    action: allow
    expressions:
      - 'event.check.occurrences == 1 || event.check.occurrences % (3600 / event.check.interval) == 0'
sensu::backend::handlers:
  email:
    ensure: present
    type: pipe
    command: "sensu-email-handler -f root@localhost -t user@example.com -s localhost -i"
    timeout: 10
    runtime_assets:
      - sensu-email-handler
    filters:
      - is_incident
      - not_silenced
      - hourly
sensu::backend::checks:
  check-cpu:
    ensure: present
    command: check-cpu.sh -w 75 -c 90
    interval: 60
    subscriptions:
      - linux
    handlers:
      - email
    publish: true
  check-disks:
    ensure: present
    command: "/opt/sensu-plugins-ruby/embedded/bin/check-disk-usage.rb -t '(xfs|ext4)'"
    subscriptions:
      - linux
    handlers:
      - email
    interval: 1800
    publish: true
```

### Resource purging

All the types provided by this module support purging except `sensu_config`.
This example will remove all unmanaged Sensu checks:

```puppet
sensu_resources { 'sensu_check':
  purge => true,
}
```

**NOTE**: The Puppet built-in `resources` can also be used for purging but you must ensure that resources that support namespaces are defined using composite names in the form of `$name in $namespace`. See [Composite Names for Namespaces](#composite-names-for-namespaces) for details on composite names.

Using the Puppet built-in `resources` would look like this:

```puppet
resources { 'sensu_check':
  purge => true,
}
```

### Sensu backend cluster

A `sensu-backend` cluster can be defined for fresh installs by defining the necessary `config_hash` values.
The following examples are using Hiera and assume the `sensu::backend` class is included.

```yaml
# data/fqdn/sensu-backend1.example.com.yaml
---
sensu::backend::config_hash:
  etcd-advertise-client-urls: "http://%{facts.ipaddress}:2379"
  etcd-listen-client-urls: "http://%{facts.ipaddress}:2379"
  etcd-listen-peer-urls: 'http://0.0.0.0:2380'
  etcd-initial-cluster: 'backend1=http://192.168.0.1:2380,backend2=http://192.168.0.2:2380'
  etcd-initial-advertise-peer-urls: "http://%{facts.ipaddress}:2380"
  etcd-initial-cluster-state: 'new'
  etcd-initial-cluster-token: ''
  etcd-name: 'backend1'
```
```yaml
# data/fqdn/sensu-backend2.example.com.yaml
---
sensu::backend::config_hash:
  etcd-advertise-client-urls: "http://%{facts.ipaddress}:2379"
  etcd-listen-client-urls: "http://%{facts.ipaddress}:2379"
  etcd-listen-peer-urls: 'http://0.0.0.0:2380'
  etcd-initial-cluster: 'backend1=http://192.168.0.1:2380,backend2=http://192.168.0.2:2380'
  etcd-initial-advertise-peer-urls: "http://%{facts.ipaddress}:2380"
  etcd-initial-cluster-state: 'new'
  etcd-initial-cluster-token: ''
  etcd-name: 'backend2'
```

#### Adding backend members to an existing cluster

Adding new members to an existing cluster requires two steps.

First, add the member to the catalog on one of the existing cluster backends with the `sensu_cluster_member` type.

```puppet
sensu_cluster_member { 'backend3':
  peer_urls => ['http://192.168.0.3:2380'],
}
```

Second, configure and start `sensu-backend` to interact with the existing cluster.
The output from Puppet when a new `sensu_cluster_member` is applied will print some of the values needed.

```yaml
# data/fqdn/sensu-backend3.example.com.yaml
---
sensu::backend::config_hash:
  etcd-advertise-client-urls: "http://%{facts.ipaddress}:2379"
  etcd-listen-client-urls: "http://%{facts.ipaddress}:2379"
  etcd-listen-peer-urls: 'http://0.0.0.0:2380'
  etcd-initial-cluster: 'backend1=http://192.168.0.1:2380,backend2=http://192.168.0.2:2380,backend3=http://192.168.0.3:2380'
  etcd-initial-advertise-peer-urls: "http://%{facts.ipaddress}:2380"
  etcd-initial-cluster-state: 'existing'
  etcd-initial-cluster-token: ''
  etcd-name: 'backend3'
```

The first step will not fully add the node to the cluster until the second step is performed.

### Sensu backend federation

Currently the federation support within this module involves configuring Etcd replicators. This allows resources to be sent from one Sensu cluster to another cluster.

It's necessary that Etcd be listening on an interface that can be accessed by other Sensu backends.

First configure backend Etcd to listen on an interface besides localhost and also use SSL:

```puppet
class { '::sensu::backend':
  config_hash => {
    'etcd-listen-client-urls' => "https://0.0.0.0:2379",
    'etcd-advertise-client-urls' => "https://0.0.0.0:2379",
    'etcd-cert-file' => "/etc/sensu/etcd-ssl/${facts['fqdn'].pem",
    'etcd-key-file' => "/etc/sensu/etcd-ssl/${facts['fqdn']}-key.pem",
    'etcd-trusted-ca-file' => "/etc/sensu/etcd-ssl/ca.pem",
    'etcd-client-cert-auth' => true,
  },
}
```

Next configure the Etcd replicator on the backend you wish to push resources from.
In the following example all defined `Role` resources will be replicated to the backend at the IP address 192.168.52.30.

```puppet
sensu_etcd_replicator { 'role_replicator':
  ensure        => 'present',
  ca_cert       => '/etc/sensu/etcd-ssl/ca.pem',
  cert          => '/etc/sensu/etcd-ssl/client.pem',
  key           => '/etc/sensu/etcd-ssl/client-key.pem',
  url           => 'https://192.168.52.30:2379',
  resource_name => 'Role',
}
sensu_role { 'test':
  ensure => 'present',
  rules  => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}],
}
```

### Large Environment Considerations

If the backend system has a large number of resources it may be necessary to query resources using chunk size added in Sensu Go 5.8.

```
class { '::sensu::backend':
  sensuctl_chunk_size => 100,
}
```

### Composite Names for Namespaces

All resources that support having a `namespace` also support a composite name to define the namespace.

For example, the `sensu_check` with name `check-cpu in team1` would be named `check-cpu` and put into the `team1` namespace.

Using composite names is necessary if you wish to have multiple resources with the same name but in different namespaces.

For example to define the same check in two namespaces using the same check name:

```puppet
sensu_check { 'check-cpu in default':
  ensure        => 'present',
  command       => 'check-cpu.sh -w 75 -c 90',
  interval      => 60,
  subscriptions => ['linux'],
}
sensu_check { 'check-cpu in team1':
  ensure        => 'present',
  command       => 'check-cpu.sh -w 75 -c 90',
  interval      => 60,
  subscriptions => ['linux'],
}
```

The example above would add the `check-cpu` check to both the `default` and `team1` namespaces.

**NOTE:** If you use composite names for namespaces, the `namespace` property takes precedence.

### Installing Bonsai Assets
Install a bonsai asset. The latest version will be installed but not automatically upgraded.

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure  => 'present',
}
```

Install specific version of a bonsai asset.

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure  => 'present',
  version => '1.2.0',
}
```

Install latest version of a bonsai asset. Puppet will update the Bonsai asset if a new version is released.
```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure  => 'present',
  version => 'latest',
}
```

### Bolt Tasks

The following Bolt tasks are provided by this Module:

**sensu::agent\_event**: Create a Sensu Go agent event via the agent API

Example: `bolt task run sensu::agent_event name=bolttest status=1 output=test --nodes sensu_agent`

**sensu::apikey**: Manage Sensu Go API keys

Example: `bolt task run sensu::apikey action=create username=foobar --nodes sensu_backend`
Example: `bolt task run sensu::apikey action=list --nodes sensu_backend`
Example: `bolt task run sensu::apikey action=delete key=replace-with-uuid-key --nodes sensu_backend`

**sensu::assets\_outdated**: Retreive outdated Sensu Go assets

Example: `bolt task run sensu::assets_outdated --nodes sensu_backend`

**sensu::check\_execute**: Execute a Sensu Go check

Example: `bolt task run sensu::check_execute check=test subscription=entity:sensu_agent --nodes sensu_backend`

**sensu::event.json**: Manage Sensu Go events

Example: `bolt task run sensu::event action=resolve entity=sensu_agent check=test --nodes sensu_backend`

Example: `bolt task run sensu::event action=delete entity=sensu_agent check=test --nodes sensu_backend`

**sensu::silenced**: Manage Sensu Go silencings

Example: `bolt task run sensu::silenced action=create subscription=entity:sensu_agent expire_on_resolve=true --nodes sensu_backend`

Example: `bolt task run sensu::silenced action=delete subscription=entity:sensu_agent --nodes sensu_backend`

**sensu::install\_agent**: Install Sensu Go agent (Windows and Linux)

Example: `bolt task run sensu::install_agent backend=sensu_backend:8081 subscription=linux output=true --nodes linux`

Example: `bolt task run sensu::install_agent backend=sensu_backend:8081 subscription=windows output=true --nodes windows`

### Bolt Inventory

This module provides a plugin to populate Bolt v2 inventory targets.

In order to use the `sensu` inventory plugin the host executing Bolt must have `sensuctl` configured, see [Basic Sensu CLI](#basic-sensu-cli).

Example of configuring the Bolt inventory with two groups. The `linux` group pulls Sensu Go entities in the `default` namespace with the `linux` subscription. The `linux-qa` group is the same as `linux` group but instead pulling entities from the `qa` namespace.

```yaml
version: 2
groups:
  - name: linux
    targets:
      - _plugin: sensu
        namespace: default
        subscription: linux
  - name: linux-qa
    targets:
      - _plugin: sensu
        namespace: qa
        subscription: linux
```

If your entities have more than one network interface it may be necessary to specify the order of interfaces to search when looking for the IP address:

```yaml
version: 2
groups:
  - name: linux
    targets:
      - _plugin: sensu
        namespace: default
        subscription: linux
        interface_list:
          - eth0
          - eth1
```

The following rules for interface matching determine the value used for `uri`.

1. If `interface_list` was defined then find first match
1. If `interface_list` not defined and only one interface, use that as ipaddress
1. If `interface_list` is not defined and more than one interface, use name

## Reference

### Facts

#### `sensu_agent`

The `sensu_agent` fact returns the Sensu agent version information by the `sensu-agent` binary.

```shell
facter -p sensu_agent
{
  version => "5.1.0",
  build => "b2ea9fcdb21e236e6e9a7de12225a6d90c786c57",
  built => "2018-12-18T21:31:11+0000"
}
```

#### `sensu_backend`

The `sensu_backend` fact returns the Sensu backend version information by the `sensu-backend` binary.

```shell
facter -p sensu_backend
{
  version => "5.1.0",
  build => "b2ea9fcdb21e236e6e9a7de12225a6d90c786c57",
  built => "2018-12-18T21:31:11+0000"
}
```

#### `sensuctl`

The `sensuctl` fact returns the sensuctl version information by the `sensuctl` binary.

```shell
facter -p sensuctl
{
  version => "5.1.0",
  build => "b2ea9fcdb21e236e6e9a7de12225a6d90c786c57",
  built => "2018-12-18T21:31:11+0000"
}
```

## Limitations

The Sensu v2 support is designed so that all resources managed by `sensuctl` are defined on the `sensu-backend` host.
This module does not support adding `sensuctl` resources on a host other than the `sensu-backend` host.

The type `sensu_user` does not at this time support `ensure => absent` due to a limitation with sensuctl, see [sensu-go#2540](https://github.com/sensu/sensu-go/issues/2540).

### Notes regarding support

This module is built for use with Puppet versions 5 and 6 and the ruby
versions associated with those releases. See `.travis.yml` for an exact
matrix of Puppet releases and ruby versions.

This module targets the latest release of the current major Puppet
version and the previous major version. Platform support will be removed
when a platform is no longer supported by Puppet, Sensu or the platform
maintainer has signaled that it is end of life (EOL).

Though Amazon does not announce end of life (EOL) for its releases, it
does encourage you to use the latest releases. This module will support
the current release and the previous release. Since AWS does not release
Vagrant boxes and the intent of those platforms is to run in AWS, we
will not maintain Vagrant systems for local development for Amazon
Linux.

### Supported Platforms

* EL 6
* EL 7
* Debian 8
* Debian 9
* Debian 10 (Puppet 6 only)
* Ubuntu 16.04 LTS
* Ubuntu 18.04 LTS
* Amazon 2018.03
* Amazon 2
* Windows Server 2008 R2
* Windows Server 2012 R2
* Windows Server 2016
* Windows Server 2019

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

See [LICENSE](LICENSE) file.
