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

This is a **Partner Supported** module. Puppet does not provide support; Sensu does at [https://sensu.io/support](https://sensu.io/support).

### Documented with Puppet Strings

[Puppet Strings documentation](https://sensu.github.io/sensu-puppet/)

### Compatibility - supported Sensu versions

This module supports Sensu Go 6.x (6.1+). Please log an issue if you identify any incompatibilities.

| Sensu Go Version | Recommended Puppet Module Version |
| ---------------- | --------------------------------- |
| 6.0              | v5.0.0                            |
| 6.1+             | v5.1.0+                           |

For older Sensu Go 5.x use module v3/v4. For Sensu Classic use [sensu/sensuclassic](https://forge.puppet.com/sensu/sensuclassic).

### Agent entity configuration

Beginning with Sensu Go 6, changes to `agent.yml` only bootstrap an agent entity — they do not update it after first registration. To change subscriptions, labels, or annotations after a host is added, the agent must make API calls.

For agents to make API calls, configure the admin password and API host:

```
class { 'sensu':
  api_host                     => 'sensu-backend.example.com',
  agent_entity_config_password => 'supersecret',
}
class { 'sensu::agent':
  ...
}
```

See [API Providers](#api-providers) for Hiera configuration that can share the admin password with agents.

This module continues to write subscriptions and other agent config to `agent.yml` so that if an agent entity is deleted, restarting `sensu-agent` recreates it.

Beginning with Sensu Go 6.2.0 you can make `agent.yml` the authoritative source for an agent's config by setting `sensu::agent::agent_managed_entity` to `true`.

## Setup

### What sensu affects

This module will install packages, create configuration and start services necessary to manage Sensu agents and backend.

### Setup requirements

#### Puppet and Ruby Version Requirements

This module supports Puppet 8 with Ruby 3.x:

| Puppet Version | Required Ruby Version | Support Status |
|----------------|----------------------|----------------|
| Puppet 8.x | Ruby 3.4.x | ✅ Supported |
| Puppet 7.x | Ruby 3.1.x | ❌ EOL (Feb 2025) |
| Puppet 6.x | Ruby 2.5.x - 2.7.x | ❌ EOL (Removed) |

**Note:** Perforce stopped publishing Puppet packages at 8.10.0. Migration to [OpenVox](https://github.com/openvoxproject) (community Puppet 8 fork by Vox Pupuli) is a viable future path.

#### Plugin Sync

Plugin sync is required if the custom sensu types and providers are used.

#### Soft module dependencies

For systems using `apt`:
  * [puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt) module (`>= 5.0.1 < 9.0.0`)

For systems using `yum` and Puppet >= 8.0.0:
  * [puppetlabs/yumrepo_core](https://forge.puppet.com/puppetlabs/yumrepo_core) module (`>= 1.0.1 < 2.0.0`)

For Windows:
  * [puppetlabs/chocolatey](https://forge.puppet.com/puppetlabs/chocolatey) module (`>= 3.0.0 < 7.0.0`)
  * [puppet/windows_env](https://forge.puppet.com/puppet/windows_env) module (`>= 3.0.0 < 5.0.0`)
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

Configures sensu-backend, sensu-agent, and a check. The backend uses Puppet's SSL certificate and CA by default. Do not use the default password.

**NOTE** When changing the password, run Puppet on the backend first.

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

Configure a sensu-agent with `linux` and `apache-servers` subscriptions:

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

Configure sensuctl:

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
  install_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/X.Y.Z/sensu-go_X.Y.Z_windows_amd64.zip',
}
```

### API Providers

All the core resources have a provider that manages resources using the Sensu Go API.
The new provider can be used by setting `provider` parameter on a resource to `sensu_api`.
The default provider is `sensuctl`; set `provider => 'sensu_api'` on any resource to use the API instead. The check below can be defined on a host that is not the `sensu-backend`:

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

The `sensu::api` class configures credentials and URL for the Sensu backend API.

Set the API URL, username, and password in the `sensu` class or via Hiera:

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

Without chocolatey, set `package_source` to a URL, Puppet source, or filesystem path.

Install sensu-go-agent on Windows from URL:

```puppet
class { 'sensu::agent':
  package_name   => 'Sensu Agent',
  package_source => 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/X.Y.Z/sensu-go-agent_X.Y.Z_en-US.x64.msi',
}
```

Install sensu-go-agent on Windows from Puppet source:

```puppet
class { 'sensu::agent':
  package_name   => 'Sensu Agent',
  package_source => 'puppet:///modules/profile/sensu/sensu-go-agent.msi',
}
```

Install from a local MSI path:

```puppet
class { 'sensu::agent':
  package_name   => 'Sensu Agent',
  package_source => 'C:\Temp\sensu-go-agent.msi',
}
```

### Advanced agent

To make `agent.yml` authoritative for agent entity configs:

```puppet
class { 'sensu::agent':
  agent_managed_entity  => true,
}
```

To change the `agent` password, provide both old and new passwords. Set `show_diff => false` to avoid exposing the password.

```puppet
class { 'sensu':
  agent_password => 'supersecret',
}
class { 'sensu::agent':
  show_diff => false,
}
```

Use `config_hash` for `agent.yml` keys not covered by `sensu::agent` parameters.

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

Subscriptions can be defined in multiple places; they are merged into `agent.yml`:

```
class { 'sensu::agent':
  subscriptions => ['base'],
}
```

In an Apache profile class:

```
sensu::agent::subscription { 'apache': }
```

The resulting `agent.yml` would contain subscriptions for both `base` and `apache`.

**NOTE**: Subscriptions defined using the `sensu::agent` class and `sensu::agent::subscription` are merged to produce the final subscription array.

### Advanced agent - Annotations and Labels

Annotations and labels can be defined in multiple places; they are merged into `agent.yml`:

```puppet
class { 'sensu::agent':
  labels      => { 'location' => 'uswest', 'contacts' => 'ops@example.com' },
  annotations => { 'cpu.warning' => '90', 'cpu.critical' => '100' },
}
```

In a profile class:

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

To redact a label or annotation, set `redact => true`; the key is added to `agent.yml`'s `redact` list:

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

### Advanced agent - Disable validations

In some cases it might be desired to disable API and entity validations when agents are managing their own entity.

```puppet
class { 'sensu':
  validate_api => false,
}
class { 'sensu::agent':
  agent_managed_entity => true,
  validate_entity      => false,
}
```

### Advanced agent - Custom config entries

Define `agent.yml` config entries from multiple locations:

```puppet
sensu::agent::config_entry { 'keepalive-interval': value => 20 }
```

This would add the following to `agent.yml`:

```yaml
keepalive-interval: 20
```

**NOTE** `sensu::agent::config_entry` takes precendence over values defined in `sensu::agent` class.

### Advanced SSL

By default, this module uses Puppet's SSL certificates and CA. To use different certificates, override `ssl_ca_source`, `ssl_cert_source`, and `ssl_key_source`. `api_host` must match the certificate CN, and agent `backends` must match the backend's certificate. For already-installed certificates, use filesystem paths.

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

To activate enterprise support, add the license file:

```puppet
class { 'sensu::backend':
  license_source => 'puppet:///modules/profile/sensu/license.json',
}
```

The types `sensu_ad_auth` and `sensu_ldap_auth` require a valid enterprise license.

### Contact routing

See [Sensu Go - Route alerts with event filters](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/route-alerts/) for background. Example Puppet configuration:

Add the sensu-go-has-contact-filter bonsai asset:

```puppet
sensu_bonsai_asset { 'sensu/sensu-go-has-contact-filter':
  ensure => 'present',
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
  ensure => 'present',
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
  command        => 'check-cpu-usage --warning 75 --critical 90',
  handlers       => ['email'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu/check-cpu-usage'],
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

Add a PostgreSQL server and database to the sensu-backend host:

```puppet
class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '16',
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

**NOTE** Set `postgresql_password` to `false` if you want the DSN to only contain a username.

### Exported resources

One approach: agents export their checks via [Exported Resources](https://puppet.com/docs/puppet/latest/lang_exported.html). Agent-side definition:

```puppet
  @@sensu_check { 'check-cpu':
    ensure        => 'present',
    command       => 'check-cpu.sh -w 75 -c 90',
    interval      => 60,
    subscriptions => ['linux'],
  }
```

Backend collects them:

```puppet
  Sensu_check <<||>>
```

### Hiera resources

All the types provided by this module can have their resources defined via Hiera. A type such as `sensu_check` would be defined via `sensu::resources::checks`.

The `sensu` class must be included either directly or via `sensu::agent` or `sensu::backend`.

Example Hiera configuration:

```yaml
sensu::resources::bonsai_assets:
  sensu/sensu-email-handler:
    ensure: present
    version: latest
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
      - sensu/sensu-email-handler
    filters:
      - is_incident
      - not_silenced
      - hourly
sensu::resources::checks:
  check-cpu:
    ensure: present
    command: check-cpu-usage --warning 75 --critical 90
    interval: 60
    subscriptions:
      - linux
    handlers:
      - email
    publish: true
    runtime_assets:
      - sensu/check-cpu-usage
  check-disks:
    ensure: present
    command: "check-disk-usage --warning 85 --critical 95"
    subscriptions:
      - linux
    handlers:
      - email
    interval: 1800
    publish: true
    runtime_assets:
      - sensu/check-disk-usage
```

### Resource purging

All the types provided by this module support purging except `sensu_config`:

```puppet
sensu_resources { 'sensu_check':
  purge => true,
}
```

To selectively purge `sensu_agent_entity_config` entries, specify the config type. The following purges only subscriptions:

```puppet
sensu_resources { 'sensu_agent_entity_config':
  purge                => true,
  agent_entity_configs => ['subscriptions'],
}
```

**NOTE**: The Puppet built-in `resources` can also be used for purging but you must ensure that resources that support namespaces are defined using composite names in the form of `$name in $namespace`. See [Composite Names for Namespaces](#composite-names-for-namespaces) for details on composite names.

With the built-in `resources` type:

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


### Sensu backend federation

This module supports Etcd replicators for replicating resources between Sensu clusters. Etcd must listen on an interface accessible to other Sensu backends. First configure backend Etcd to listen on a non-localhost interface with SSL:

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

Next, configure the Etcd replicator on the source backend. The example below replicates all `Role` resources to 192.168.52.30:

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

To define a federated cluster:

```puppet
sensu_cluster_federation { 'us-west-2a':
  ensure   => 'present',
  api_urls => [
    'https://sensu-backend-site1.example.com:8080',
    'https://sensu-backend-site2.example.com:8080',
  ],
}
```

To add a backend to an existing federated cluster:

```puppet
sensu_cluster_federation_member { 'https://sensu-backend-site3.example.com:8080 in us-west-2a':
  ensure => 'present',
}
```

Equivalently:

```puppet
sensu_cluster_federation_member { 'https://sensu-backend-site3.example.com:8080':
  ensure  => 'present',
  cluster => 'us-west-2a',
}
```

### Large Environment Considerations

For backends with many resources, set a chunk size:

```
class { 'sensu::backend':
  sensuctl_chunk_size => 100,
}
```

With thousands of resources like `sensu_check`, each resource triggers a `sensuctl namespace list` call to validate the namespace (the `sensu_api` provider does the same). To eliminate this overhead when namespaces are managed outside Puppet, disable namespace validation:

**NOTE**: With namespace validation disabled, namespaces must be defined in Puppet to assign resources to them.

```puppet
class { 'sensu':
  validate_namespaces => false,
}
```

### Composite Names for Namespaces

All resources that support having a `namespace` also support a composite name to define the namespace.

For example, the `sensu_check` with name `check-cpu in team1` would be named `check-cpu` and put into the `team1` namespace.

Use composite names when the same resource name appears in multiple namespaces.

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

Bonsai assets are the modern replacement for the former `sensu::plugins` class. Where you previously used `sensu::plugins { plugins => ['disk-checks'] }`, use `sensu_bonsai_asset` with the corresponding Bonsai namespace/name instead (e.g. `sensu/sensu-plugins-disk-checks`).

Install a Bonsai asset. The current version at time of the first Puppet run will be installed but not automatically upgraded.

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure => 'present',
}
```

Install a specific version:

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure  => 'present',
  version => '1.2.0',
}
```

Track the latest version. Puppet will upgrade the asset whenever a new version is released on Bonsai.

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure  => 'present',
  version => 'latest',
}
```

Register the asset under a custom name using `rename`. This is useful when existing checks reference a different asset name in their `runtime_assets` list.

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure => 'present',
  rename => 'pagerduty-handler',
}
```

Install into a non-default Sensu RBAC namespace using a composite title (`bonsai_namespace/bonsai_name in sensu_namespace`):

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler in ops':
  ensure => 'present',
}
```

Use a proxy to reach Bonsai:

```puppet
sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure           => 'present',
  bonsai_http_proxy => 'http://proxy.example.com:3128',
}
```

Manage multiple Bonsai assets via Hiera using `sensu::resources::bonsai_assets`:

```yaml
sensu::resources::bonsai_assets:
  'sensu/sensu-pagerduty-handler':
    ensure: present
    version: '1.2.0'
  'sensu/sensu-plugins-disk-checks':
    ensure: present
    version: latest
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

To use the `sensu` inventory plugin, the Bolt host must have `sensuctl` configured (see [Basic Sensu CLI](#basic-sensu-cli)).

Two groups — `linux` (default namespace) and `linux-qa` (qa namespace):

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

For entities with multiple network interfaces, specify the interface search order:

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
  version => "6.11.0",
  build => "a3a4e39cb3fe0f7b4ff4e6a19c6e1bb5b3cdfbf2",
  built => "2024-03-01T00:00:00+0000"
}
```

#### `sensu_backend`

The `sensu_backend` fact returns the Sensu backend version information by the `sensu-backend` binary.

```shell
facter -p sensu_backend
{
  version => "6.11.0",
  build => "a3a4e39cb3fe0f7b4ff4e6a19c6e1bb5b3cdfbf2",
  built => "2024-03-01T00:00:00+0000"
}
```

#### `sensuctl`

The `sensuctl` fact returns the sensuctl version information by the `sensuctl` binary.

```shell
facter -p sensuctl
{
  version => "6.11.0",
  build => "a3a4e39cb3fe0f7b4ff4e6a19c6e1bb5b3cdfbf2",
  built => "2024-03-01T00:00:00+0000"
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
* [SSL Backend](https://github.com/sensu/sensu-puppet/blob/master/examples/ssl-backend.pp) - Example of Sensu backend with SSL/TLS enabled

## Limitations

Changing `sensu::etc_dir` is only supported on systems using systemd.

The type `sensu_user` does not at this time support `ensure => absent` due to a limitation with sensuctl, see [sensu-go#2540](https://github.com/sensu/sensu-go/issues/2540).

When changing `sensu::password`, run Puppet on the backend first.

### Notes regarding support

This module targets Puppet 8. See `.github/workflows/` for the exact Puppet/Ruby version matrix.

Platform support is removed when a platform is EOL per Puppet, Sensu, or the platform maintainer.

Amazon Linux 2 reached EOL June 2025 and has been removed. Amazon Linux 2023
is the supported Amazon Linux release.

### Supported Platforms

* EL 8 (Rocky 8, AlmaLinux 8)
* EL 9 (Rocky 9, AlmaLinux 9)
* Debian 12
* Ubuntu 22.04 LTS
* Ubuntu 24.04 LTS
* Amazon Linux 2023
* Windows Server 2016, 2019, 2022 (sensu-agent and sensuctl only)

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

See [LICENSE](LICENSE) file.
