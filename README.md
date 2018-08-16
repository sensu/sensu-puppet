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

This module has a soft dependency on the [puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt) module (`>= 4.0.0 < 5.0.0`) for systems using `apt`.

### Beginning with sensu

This module provides Vagrant definitions that can be used to get started with Sensu.

```bash
vagrant up sensu-backend
vagrant ssh sensu-backend
```

## Usage

### Basic Sensu backend

The following example will configure sensu-backend and add a check.  It's advisable to not rely on the default password.

```puppet
  class { 'sensu::backend':
    password => 'P@ssw0rd!',
  }
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
This example will remove all unmanaged Sensu checks:

```puppet
resources { 'sensu_check':
  purge => true,
}
```

## Reference

### Facts

#### `sensu_version`

The `sensu_version` fact returns the Sensu Agent version returned by the `sensu-agent` binary.

```shell
facter -p sensu_version
2.0.0
```

## Limitations

The Sensu v2 support is designed so that all resources managed by `sensuctl` are defined on the `sensu-backend` host.
This module does not support adding `sensuctl` resources on a host other than the `sensu-backend` host.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

See [LICENSE](LICENSE) file.
