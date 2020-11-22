# Sensu-Puppet

#### Table of Contents

1. [Module Description](#module-description)
    * [Updating this module from 4.x to 5.x](#updating-this-module-from-4x-to-5x)
    * [Updating this module from 3.x to 4.x](#updating-this-module-from-3x-to-4x)
2. [Setup - The basics of getting started with Sensu](#setup)
    * [What sensu affects](#what-sensu-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Sensu](#beginning-with-sensu)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Location of Resources](#location-of-resources)
    * [Basic Sensu backend](#basic-sensu-backend)
    * [Basic Sensu agent](#basic-sensu-agent)
    * [Basic Sensu CLI](#basic-sensu-cli)
    * [API Providers](#api-providers)
    * [Manage Windows Agent](#manage-windows-agent)
    * [Advanced agent](#advanced-agent)
    * [Advanced agent - Subscriptions](#advanced-agent---subscriptions)
    * [Advanced agent - Annotations and Labels](#advanced-agent---annotations-and-labels)
    * [Advanced agent - Custom config entries](#advanced-agent---custom-config-entries)
    * [Advanced SSL](#advanced-ssl)
    * [Enterprise support](#enterprise-support)
    * [Contact routing](#contact-routing)
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
5. [Examples](#examples)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [License](#license)

## Module description

Installs and manages [Sensu Go](https://sensu.io/), the open source monitoring framework.

Please note, that this is a **Partner Supported** module, which means that technical customer support for this module is solely provided by Sensu. Puppet does not provide support for any **Partner Supported** modules. Technical support for this module is provided by Sensu at [https://sensu.io/support](https://sensu.io/support).

### Documented with Puppet Strings

[Puppet Strings documentation](http://sensu.github.io/sensu-puppet/)

### Compatibility - supported Sensu versions

If not explicitly stated it should always support the latest Sensu release.
Beginning with v5.0.0 this module will only support Sensu Go 6.0+.
Please log an issue if you identify any incompatibilities.

| Sensu Go Version| Recommended Puppet Module Version   |
| --------------- | ----------------------------------- |
| 5.0 - 5.15      | latest v3                           |
| 5.16+           | latest v4                           |
| 6.0             | v5.0.0                              |
| 6.1+            | v5.1.0+

### Upgrade note

Sensu Go 5.x is a rewrite of Sensu and no longer depends on redis and rabbitmq.
Version 3 of this module supports Sensu Go >= 5.0.0 to < 5.16.0.
Version 4 of this module supports Sensu Go >= 5.16.0 < 6.0.0.
Version 5.0.0 of this module supports Sensu Go >= 6.0.0 < 6.1.0.
Version 5.1.0+ of this module supports Sensu Go >= 6.1.0 < 7.0.0.

Users wishing to use the previous Ruby based Sensu should use the [sensu/sensuclassic](https://forge.puppet.com/sensu/sensuclassic) module.

### Updating this module from 4.x to 5.x

This module begins supporting Sensu Go 6 with version >= 5.0.0

**NOTE** Upgrading to support Sensu Go 6 requires backends have Puppet applied before agents will begin to work as there is an agent specifc Sensu user and role added to support modifying agent entities via the API.

Class parameter changes:

* Remove deprecated `sensu::old_password` and `sensu::old_agent_password`, these parameters are no longer needed and were removed

Type property changes:

* Remove deprecated `url`, `sha512` and `filters` properties from `sensu_asset`, use `builds` property instead

#### Changes for backend

There is a manual step to perform to upgrade the sensu-backend after upgrading the backend to 6.x.
This module provides the `sensu::backend_upgrade` bolt task as a way to execute the necessary `sensu-backend upgrade` command.

#### Changes for agents

Beginning with Sensu Go 6, some changes to `agent.yml` will only bootstrap an agent entity, they will not update the entity.
If you wish to make changes to values such as `subscriptions`, `labels` or `annotations` after a host is added to Sensu this must be done
via the Sensu Go API. To support this it's now required that agents have the ability to make API calls.

In order to ensure agents can make API calls either via API or sensuctl the agent must be told about the admin password and API host:

```
class { 'sensu':
  api_host                     => 'sensu-backend.example.com',
  agent_entity_config_password => 'supersecret',
}
class { 'sensu::agent':
  ...
}
```

See [API Providers](#api-providers) for example Hiera that can be used in a file like `common.yaml` to easily share the admin password with agents.

This module will still continue to write subscriptions and other agent configurations to `agent.yml` so that if an agent entity is deleted it can be recreated
by restarting the `sensu-agent` service.

### Updating this module from 3.x to 4.x

Class parameter changes:

* Move `sensu::backend::cli_package_name` to `sensu::cli::package_name`
* Move `sensu::backend::sensuctl_chunk_size` to `sensu::cli::sensuctl_chunk_size`
* Move `sensu::backend::url_host` to `sensu::api_host`
* Move `sensu::backend::url_port` to `sensu::api_port`
* Move `sensu::backend::password` to `sensu::password`
* Move `sensu::backend::old_password` to `sensu::old_password`
* Move `sensu::backend::agent_password` to `sensu::agent_password`
* Move `sensu::backend::agent_old_password` to `sensu::agent_old_password`
* The following parameters were moved from `sensu::backend` class to `sensu::resources` class. (**Example:** `sensu::backend::checks` becomes `sensu::resources::checks`)
  * `ad_auths`
  * `assets`
  * `bonsai_assets`
  * `checks`
  * `cluster_members`
  * `cluster_role_bindings`
  * `cluster_roles`
  * `configs` (removed)
  * `entities`
  * `etcd_replicators`
  * `filters`
  * `handlers`
  * `hooks`
  * `ldap_auths`
  * `mutators`
  * `namespaces`
  * `oidc_auths`
  * `role_bindings`
  * `roles`
  * `users`

Type property changes:

* Replace `sensu_check` `proxy_requests*` properties with `proxy_requests` Hash
* Replace `sensu_entity` `deregistration_handler` with `deregistration` Hash
* Replace `sensu_handler` `socket_*` properties with `socket` Hash
* Refactor `sensu_ldap_auth` and `sensu_ad_auth` on how properties are defined.
  * Move `server_binding`, `server_group_search` and `server_user_search` into `servers` property

Breaking changes:

* Remove `sensu_event` type, replaced with `sensu::event` Bolt task
* Remove `sensu_silenced` type, replaced with `sensu::silenced` Bolt task
* Remove `sensu_config` type, replaced with `sensu::cli::config_format` and `sensu::cli::config_namespace` parameters

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
  * [puppet/archive](https://forge.puppet.com/puppet/archive) module (`>= 3.0.0 < 5.0.0`)

### Beginning with Sensu

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

### Location of Resources

Sensu Go is designed to have resources like checks and assets defined on the backend host.
For Puppet this means that the simplest configuration will be one where checks and other resources are defined on the host using `sensu::backend` class.
Hosts with only the `sensu::agent` class do not need to have checks defined on them, rather just have to have a subscription assigned that matches a check.

### Basic Sensu backend

The following example will configure sensu-backend, sensu-agent on backend and add a check.
By default this module will configure the backend to use Puppet's SSL certificate and CA.
It is advisable to not rely on the default password.
**NOTE** When changing the password value, it's necessary to run Puppet on the backend first to update the `admin` password.

```puppet
  class { 'sensu':
    password => 'supersecret',
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
  class { 'sensu':
    api_host                     => 'sensu-backend.example.com',
    agent_entity_config_password => 'supersecret',
  }
  class { 'sensu::agent':
    backends      => ['sensu-backend.example.com:8081'],
    subscriptions => ['linux', 'apache-servers'],
  }
```

### Basic Sensu CLI

The following example will manage the resources necessary to use `sensuctl`.

```puppet
class { 'sensu':
  api_host => 'sensu-backend.example.com',
  password => 'supersecret',
}
include sensu::cli
```

**NOTE**: The `sensu::backend` class calls the `sensu::cli` class so it is only necessary to directly call the `sensu::cli` class on hosts not using the `sensu::backend` class.

For Windows the `install_source` parameter must be provided:

```puppet
class { 'sensu':
  api_host => 'sensu-backend.example.com',
  password => 'supersecret',
}
class { 'sensu::cli':
  install_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.14.1/sensu-go_5.14.1_windows_amd64.zip',
}
```

### API Providers

All the core resources have a provider that manages resources using the Sensu Go API.
The new provider can be used by setting `provider` parameter on a resource to `sensu_api`.
The default provider is still `sensuctl` but it's possible to change the provider when defining a resource.
For example the following will create a check which can be defined on an host that's not the `sensu-backend`.

```
include ::sensu::api
sensu_check { "check-cpu-${facts['hostname']}":
  ensure        => 'present',
  command       => 'check-cpu.sh -w 75 -c 90',
  interval      => 60,
  subscriptions => ["entity:${facts['hostname']}"],
  provider      => 'sensu_api',
}
```

The `sensu::api` class is required in order to configure the credentials and URL used to communicate with the Sensu backend API.

The API URL, username and password used for the API are set in the `sensu` class and can be set easily with Hiera:

```yaml
sensu::api_host: sensu-backend.example.com
sensu::api_port: 8080
sensu::username: admin
sensu::password: supersecret
sensu::agent_entity_config_password: supersecret
```

### Manage Windows Agent

This module supports Windows Sensu Go agent via chocolatey beginning with version 5.12.0.

```puppet
class { 'sensu':
  api_host                     => 'sensu-backend.example.com',
  agent_entity_config_password => 'supersecret',
}
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
It is advisable to set `show_diff` to `false` to avoid exposing the agent password.

```puppet
class { 'sensu':
  agent_password => 'supersecret',
}
class { 'sensu::agent':
  show_diff => false,
}
```

The `config_hash` parameter allows custom configuration for `agent.yml` outside the `sensu::agent` class parameters.

```puppet
class { 'sensu::agent':
  config_hash => {
    'log-level' => 'debug',
  },
}
```

The following parameters in `sensu::agent` class are used to populate `agent.yml`:

* entity_name - Passed to `name` key in `agent.yml`
* subscriptions
* annotations
* labels
* namespace
* redact

Agent configurations can also be set via `sensu::agent::config_entry`. See [Advanced agent - Custom config entries](#advanced-agent---custom-config-entries).

### Advanced agent - Subscriptions

It is possible to define subscriptions in many locations and the values merged into `agent.yml`:

```
class { 'sensu::agent':
  subscriptions => ['base'],
}
```

Then in a profile class for Apache you could define the following:

```
sensu::agent::subscription { 'apache': }
```

The resulting `agent.yml` would contain subscriptions for both `base` and `apache`.

**NOTE**: Subscriptions defined using the `sensu::agent` class and `sensu::agent::subscription` are merged to produce the final subscription array.

### Advanced agent - Annotations and Labels

It is possible to define annotations and labels in many locations and the values merged into `agent.yml`:

```puppet
class { 'sensu::agent':
  labels      => { 'location' => 'uswest', 'contacts' => 'ops@example.com' },
  annotations => { 'cpu.warning' => '90', 'cpu.critical' => '100' },
}
```

Then in a profile class you can define the following:

```puppet
sensu::agent::label { 'contacts': value => 'devs@example.com' }
sensu::agent::label { 'environment': value => 'dev' }
sensu::agent::annotation { 'cpu.warning': value => '75' }
sensu::agent::annotation { 'fatigue_check/occurrences': value => '2' }
```

The resulting `agent.yml` will contain the following:

```yaml
labels:
  location: uswest
  contacts: devs@example.com
  environment: dev
annotations:
  cpu.warning: '75'
  cpu.critical: '100'
  fatigue_check/occurrences: '2'
```

**NOTE** `sensu::agent::annotation` and `sensu::agent::label` take precedence over values set by the class `sensu::agent`

If you wish to redact a label or annotation you can use the `redact` parameter and the key will be added to the `redact` list in `agent.yml`:

```puppet
sensu::agent::label { 'secret':
  value  => 'mysecret',
  redact => true,
}
sensu::agent::annotation { 'ec2_access_key':
  value  => 'some-key',
  redact => true,
}
```

### Advanced agent - Custom config entries

It is possible to define config entries for `agent.yml` in many locations in Puppet:

```puppet
sensu::agent::config_entry { 'keepalive-interval': value => 20 }
```

This would add the following to `agent.yml`:

```yaml
keepalive-interval: 20
```

**NOTE** `sensu::agent::config_entry` takes precendence over values defined in `sensu::agent` class.

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

### Contact routing

See [Sensu Go - Contact Routing](https://docs.sensu.io/sensu-go/latest/guides/contact-routing/) for details. The following is one way to configure contact routing in Puppet.

Add the sensu-go-has-contact-filter bonsai asset:

```puppet
sensu_bonsai_asset { 'sensu/sensu-go-has-contact-filter':
  ensure  => 'present',
  version => '0.2.0',
}
```

Add the filters for the defined contacts

```puppet
sensu_filter { 'contact_dev':
  ensure         => 'present',
  action         => 'allow',
  runtime_assets => ['sensu/sensu-go-has-contact-filter'],
  expressions    => ['has_contact(event, "dev")'],
}
sensu_filter { 'contact_ops':
  ensure         => 'present',
  action         => 'allow',
  runtime_assets => ['sensu/sensu-go-has-contact-filter'],
  expressions    => ['has_contact(event, "ops")'],
}
```

Add the handlers asset and  handlers for each contact

```puppet
sensu_bonsai_asset { 'sensu/sensu-email-handler':
  ensure  => 'present',
  version => '0.2.0',
}
sensu_handler { 'email_dev':
  ensure          => 'present',
  type            => 'pipe',
  command         => 'sensu-email-handler -f root@localhost -t dev@example.com -s localhost -i',
  timeout         => 10,
  runtime_assets  => ['sensu/sensu-email-handler'],
  filters         => ['is_incident','not_silenced','contact_dev'],
}
sensu_handler { 'email_ops':
  ensure          => 'present',
  type            => 'pipe',
  command         => 'sensu-email-handler -f root@localhost -t ops@example.com -s localhost -i',
  timeout         => 10,
  runtime_assets  => ['sensu/sensu-email-handler'],
  filters         => ['is_incident','not_silenced','contact_ops'],
}
```

Create a handler set to centralize handler management for emails

```puppet
sensu_handler { 'email':
  ensure    => 'present',
  type      => 'set',
  handlers  => ['email_dev','email_ops'],
}
```

Lastly define a service that use the contact and the email handler:

```puppet
sensu_check { 'check_cpu':
  ensure         => 'present',
  labels         => {
    'contacts' => 'dev, ops',
  },
  command        => 'check-cpu.rb -w 75 -c 90',
  handlers       => ['email'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu-plugins-cpu-checks','sensu-ruby-runtime'],
}
```

Agents can also have contacts defined:

```puppet
class { 'sensu::agent':
  labels => {
    'contacts' => 'dev, ops',
  },
}
```

### PostgreSQL datastore support

**NOTE**: This features require a valid Sensu Go enterprise license.

The following example will add a PostgreSQL server and database to the sensu-backend host and configure Sensu Go to use PostgreSQL as the event datastore.

```puppet
class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '9.6',
}
class { 'postgresql::server': }
class { 'sensu::backend':
  license_source      => 'puppet:///modules/profile/sensu/license.json',
  datastore           => 'postgresql',
  postgresql_password => 'secret',
}
```

Refer to the [puppetlabs/postgresql](https://forge.puppet.com/puppetlabs/postgresql) module documentation for details on how to manage PostgreSQL with Puppet.

The following example uses an external PostgreSQL server.

```puppet
class { 'sensu::backend':
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
    password => 'supersecret',
  }
  include sensu::backend
  class { 'sensu::plugins':
    extensions => ['graphite'],
  }
```

The `extensions` parameter can also be a Hash that sets the version:

```puppet
  class { 'sensu':
    password => 'supersecret',
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
    password => 'supersecret',
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

All the types provided by this module can have their resources defined via Hiera. A type such as `sensu_check` would be defined via `sensu::resources::checks`.

The `sensu` class must be included either directly or via `sensu::agent` or `sensu::backend`.

The following example adds an asset, filter, handler and checks via Hiera:

```yaml
sensu::resources::assets:
  sensu-email-handler:
    ensure: present
    url: 'https://github.com/sensu/sensu-email-handler/releases/download/0.1.0/sensu-email-handler_0.1.0_linux_amd64.tar.gz'
    sha512: '755c7a673d94997ab9613ec5969666e808f8b4a8eec1ba998ee7071606c96946ca2947de5189b24ac34a962713d156619453ff7ea43c95dae62bf0fcbe766f2e'
    filters:
      - "entity.system.os == 'linux'"
      - "entity.system.arch == 'amd64'"
sensu::resources::filters:
  hourly:
    ensure: present
    action: allow
    expressions:
      - 'event.check.occurrences == 1 || event.check.occurrences % (3600 / event.check.interval) == 0'
sensu::resources::handlers:
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
sensu::resources::checks:
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

To selectively purge `sensu_agent_entity_config` entries, you can specify the type of config to purge.
If `agent_entity_configs` is omitted then all unmanaged `sensu_agent_entity_config` resources will be purged.
The following example will only purge subscriptions:

```puppet
sensu_resources { 'sensu_agent_entity_config':
  purge                => true,
  agent_entity_configs => ['subscriptions'],
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

This module supports defining Etcd replicators which allows resources to be sent from one Sensu cluster to another cluster.
It is necessary that Etcd be listening on an interface that can be accessed by other Sensu backends.
First configure backend Etcd to listen on an interface besides localhost and also use SSL:

```puppet
class { 'sensu::backend':
  config_hash => {
    'etcd-listen-client-urls'    => "https://0.0.0.0:2379",
    'etcd-advertise-client-urls' => "https://0.0.0.0:2379",
    'etcd-cert-file'             => "/etc/sensu/etcd-ssl/${facts['fqdn'].pem",
    'etcd-key-file'              => "/etc/sensu/etcd-ssl/${facts['fqdn']}-key.pem",
    'etcd-trusted-ca-file'       => "/etc/sensu/etcd-ssl/ca.pem",
    'etcd-client-cert-auth'      => true,
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

This module also supports defining a federated cluster:

```puppet
sensu_cluster_federation { 'us-west-2a':
  ensure   => 'present',
  api_urls => [
    'https://sensu-backend-site1.example.com:8080',
    'https://sensu-backend-site2.example.com:8080',
  ],
}
```

It is also possible to add a backend to an existing Sensu federated cluster.
The following example adds the API URL https://sensu-backend-site3.example.com:8080 to the federated cluster named us-west-2a.

```puppet
sensu_cluster_federation_member { 'https://sensu-backend-site3.example.com:8080 in us-west-2a':
  ensure => 'present',
}
```

The above can also be defined using the following example:

```puppet
sensu_cluster_federation_member { 'https://sensu-backend-site3.example.com:8080':
  ensure  => 'present',
  cluster => 'us-west-2a',
}
```

### Large Environment Considerations

If the backend system has a large number of resources it may be necessary to query resources using chunk size added in Sensu Go 5.8.

```
class { 'sensu::backend':
  sensuctl_chunk_size => 100,
}
```

If many thousands of resources such as `sensu_check` are defined there will be an execution of `sensuctl namespace list` for each check to validate
the namespace exists if the namespace is not defined in Puppet.
A similar validation is performed with `sensu_api` provider.  To avoid this extra overhead it may be necessary to disable this validation if you
are defining namespaces outside of Puppet.

**NOTE**: If namespace validation is disabled it's necessary to ensure a namespace is defined in Puppet in order to assign resources to that namespace.

```puppet
class { 'sensu':
  validate_namespaces => false,
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

**sensu::backend\_upgrade**: Perform backend upgrade via `sensu-backend upgrade` command.

Example: `bolt task run sensu::backend_upgrade --targets sensu_backend`

**sensu::agent\_event**: Create a Sensu Go agent event via the agent API

Example: `bolt task run sensu::agent_event name=bolttest status=1 output=test --targets sensu_agent`

**sensu::apikey**: Manage Sensu Go API keys

Example: `bolt task run sensu::apikey action=create username=foobar --targets sensu_backend`
Example: `bolt task run sensu::apikey action=list --targets sensu_backend`
Example: `bolt task run sensu::apikey action=delete key=replace-with-uuid-key --targets sensu_backend`

**sensu::assets\_outdated**: Retreive outdated Sensu Go assets

Example: `bolt task run sensu::assets_outdated --targets sensu_backend`

**sensu::check\_execute**: Execute a Sensu Go check

Example: `bolt task run sensu::check_execute check=test subscription=entity:sensu_agent --targets sensu_backend`

**sensu::event.json**: Manage Sensu Go events

Example: `bolt task run sensu::event action=resolve entity=sensu_agent check=test --targets sensu_backend`

Example: `bolt task run sensu::event action=delete entity=sensu_agent check=test --targets sensu_backend`

**sensu::silenced**: Manage Sensu Go silencings

Example: `bolt task run sensu::silenced action=create subscription=entity:sensu_agent expire_on_resolve=true --targets sensu_backend`

Example: `bolt task run sensu::silenced action=delete subscription=entity:sensu_agent --targets sensu_backend`

**sensu::install\_agent**: Install Sensu Go agent (Windows and Linux)

Example: `bolt task run sensu::install_agent backend=sensu_backend:8081 subscription=linux output=true --targets linux`

Example: `bolt task run sensu::install_agent backend=sensu_backend:8081 subscription=windows output=true --targets windows`

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

## Examples

Examples can be found in the [examples](https://github.com/sensu/sensu-puppet/tree/master/examples) directory.

* [Contact Routing](https://github.com/sensu/sensu-puppet/blob/master/examples/contact_routing.pp) - Example of contact routing
* [Email Alerts](https://github.com/sensu/sensu-puppet/blob/master/examples/email_alerts.pp) - Example of setting up e-mail alerts
* [InfluxDB Handler](https://github.com/sensu/sensu-puppet/blob/master/examples/influxdb_handler.pp) - Example of setting up InfluxDB handler
* [LDAP](https://github.com/sensu/sensu-puppet/blob/master/examples/ldap.pp) - Example of setting up LDAP authentication
* [Logging](https://github.com/sensu/sensu-puppet/blob/master/examples/logging.pp) - Example of setting up improved logging
* [Pagerduty with Secrets Env Vars](https://github.com/sensu/sensu-puppet/blob/master/examples/pagerduty-with-secrets-env.pp) - Setting up Pagerduty using environment variable secrets
* [Pagerduty with Secrets vault](https://github.com/sensu/sensu-puppet/blob/master/examples/pagerduty-with-secrets-vault.pp) - Setting up Pagerduty using secrets vault
* [PostgreSQL with Replication](https://github.com/sensu/sensu-puppet/tree/master/examples/postgresql-replication) - Contains example manifests of setting up Sensu backend and PostgreSQL with PostgreSQL replication.
* [PostgreSQL with SSL](https://github.com/sensu/sensu-puppet/tree/master/examples/postgresql-ssl) - Contains example manifests of setting up Sensu backend and PostgreSQL to communicate using SSL.
* [Slack Alerts](https://github.com/sensu/sensu-puppet/blob/master/examples/slack_alerts.pp) - Example of setting up Slack alerts

## Limitations

Changing `sensu::etc_dir` is only supported on systems using systemd.

The type `sensu_user` does not at this time support `ensure => absent` due to a limitation with sensuctl, see [sensu-go#2540](https://github.com/sensu/sensu-go/issues/2540).

When changing the `sensu::password` value, it's necessary to run Puppet on the backend first to update the `admin` password.

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
* EL 8
* Debian 9
* Debian 10
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
