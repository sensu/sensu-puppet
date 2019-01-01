# Sensu-Puppet

#### Table of Contents

1. [Module Description](#module-description)
2. [Setup - The basics of getting started with sensu](#setup)
    * [What sensu affects](#what-sensu-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sensu](#beginning-with-sensu)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Basic Sensu backend](#basic-sensu-backend)
    * [Basic Sensu agent](#basic-sensu-agent)
    * [Exported resources](#exported-resources)
    * [Resource purging](#resource-purging)
    * [Sensu backend cluster](#sensu-backend-cluster)
        * [Adding backend members to an existing cluster](#adding-backend-members-to-an-existing-cluster)
4. [Reference](#reference)
    * [Facts](#facts)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [License](#license)

## Module description

Installs and manages [Sensu](http://sensuapp.org), the open source monitoring framework.

Please note, that this is a **Partner Supported** module, which means that technical customer support for this module is solely provided by Sensu. Puppet does not provide support for any **Partner Supported** modules. Technical support for this module is provided by Sensu at [https://sensuapp.org/support](https://sensuapp.org/support).

### Documented with Puppet Strings

[Puppet Strings documentation](http://sensu.github.io/sensu-puppet/doc/)

### Compatibility - supported sensu versions

If not explicitly stated it should always support the latest Sensu release.
Please log an issue if you identify any incompatibilities.

| Sensu Version   | Recommended Puppet Module Version   |
| --------------- | ----------------------------------- |
| 2.x             | latest v3 |
| 0.26.0 - 1.x    | latest v2 |
| 0.22.x - 0.25.x | 2.1.0                               |
| 0.20.x - 0.21.x | 2.0.0                               |
| 0.17.x - 0.19.x | 1.5.5                               |


### Upgrade note

Sensu v2 is a rewrite of Sensu and no longer depends on redis and rabbitmq. Version 3 of this module supports Sensu v2.

## Setup

### What sensu effects

This module will install packages, create configuration and start services necessary to manage Sensu agents and backend.

### Setup requirements

Plugin sync is required if the custom sensu types and providers are used.

This module has a soft dependency on the [puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt) module (`>= 5.0.1 < 7.0.0`) for systems using `apt`.

If using Puppet >= 6.0.0 there is a soft dependency on the [puppetlabs/yumrepo_core](https://forge.puppet.com/puppetlabs/yumrepo_core) module (`>= 1.0.1 < 2.0.0`) for systems using `yum`.

### Beginning with sensu

This module provides Vagrant definitions that can be used to get started with Sensu.

```bash
vagrant up sensu-backend
vagrant ssh sensu-backend
```

#### Beginning with a Sensu cluster

Multiple Vagrant boxes are available for testing a sensu-backend cluster

```bash
vagrant up sensu-backend-peer1 sensu-backend-peer2
vagrant provision sensu-backend-peer1 sensu-backend-peer2
```

## Usage

### Basic Sensu backend

The following example will configure sensu-backend, sensu-agent on backend and add a check.

```puppet
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
    config_hash => {
      'backend-url'  => 'ws://sensu-backend.example.com:8081',
      'subscriptions => ['linux', 'apache-servers'],
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

### Resource purging

All the types provided by this module support purging except `sensu_config`.
At this time `sensu_asset` can not be purged, see [Limitations](#limitations).
This example will remove all unmanaged Sensu checks:

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

The type `sensu_asset` does not at this time support `ensure => absent` due to a limitation with sensuctl, see [sensu-go#988](https://github.com/sensu/sensu-go/issues/988).

The sensuctl username and password can not be configured by this module due to limitations with sensuctl.
This module uses the default username `admin` and default password `P@ssw0rd!`.
The checklist at [sensu-puppet#901](https://github.com/sensu/sensu-puppet/issues/901) will be updated as progress is made.

To change the `admin` password used by sensuctl the following steps can be taken:
```
sensuctl user change-password admin --current-password 'P@ssw0rd!' --new-password 'changeme'
sensuctl configure -n --username admin --password 'changeme'
```
Update the `sensu::backend::password` parameter to the new value in case `sensuctl configure` has to be run via `sensu_configure` type.


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
* Ubuntu 14.04 LTS
* Ubuntu 16.04 LTS
* Ubuntu 18.04 LTS
* Amazon 2018.03
* Amazon 2

The following platforms will be supported again once packages are released.

* Debian 8
* Debian 9

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

See [LICENSE](LICENSE) file.
