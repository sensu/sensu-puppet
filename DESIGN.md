# Module Design

## Classes

Seven main public classes (add more as needed):

* sensu - Define variables used by all other classes
* sensu::agent - Sensu Agent
* sensu::backend - Sensu Backend
* sensu::cli - Manage sensuctl
* sensu::api - Configure sensu_api providers
* sensu::resources - Define sensu resources
* sensu::plugins - Sensu plugins

The class `sensu::common` is a private class that holds resources shared by many public classes.

Subclasses like `sensu::backend::default_resources` extend a public class and keep the main class shorter. Shared private classes like `sensu::ssl` are used across multiple public classes.

If a parameter is used by multiple public classes, it belongs in `sensu` class. All other parameters should be added to the appropriate public class.

## Types/Provides

### Sensuctl types

Types for `sensuctl` resources closely match Sensu Go resource specs; for example, `interval` in a Sensu Go check maps directly to `interval` in `sensu_check`.

Keys in the Sensu Go specification under `spec` should have a 1-to-1 mapping with Puppet type properties.

The exception is Sensu Go resource `metadata`. The values for `metadata` keys of `name`, `namespace`, `labels`, and `annotations` are pulled out into Puppet type properties to handle composite names and namespace relationships.

### All other types/providers

Custom types replace complex `Exec` resources where possible. For example, `sensu_bonsai_asset` manages Bonsai asset installation without requiring manual `sensuctl` invocations, and `sensu_plugin` manages Sensu Go plugins without using `sensuctl`.

The use of Exec is acceptable for simple cases like adding the license file where the Exec can be triggered when a file changes.

### Helper functions for types

The helper code for types is found in `lib/puppet_x/sensu`. The following currently exist as helper classes for type properties:

* `array_of_hashes_property.rb` - Parent class for properties that are an Array of Hashes
* `array_property.rb` - Parent class for properties that are an Array
* `hash_property.rb` - Parent class for properties that are a Hash
* `integer_property.rb` - Parent class for properties that are an Integer

The module defined in `lib/puppet_x/sensu/type.rb` is included by all custom types of this module and provides functions that can be used to provide common logic:

* `add_autorequires` - Adds autorequires common between all types.
* `validate_namespace` - Helper function to be used in `pre_run_check` to validate a type's namespace.
* `error_prefix` - Helper function to produce meaningful string used with error messages in this module's types.

## Unit tests

Unit tests validate Puppet catalog behavior, not behavior on a running system.

Test locations:

* `spec/classes` - Tests for each class in the `manifests` directory.
* `spec/unit/*_spec.rb` - These are tests for the types defined in `lib/puppet/types`
* `spec/unit/provider/**/*_spec.rb` - These are tests for the providers defined in `lib/puppet/providers`
* `spec/unit/facter/*_spec.rb` - These are tests for custom facts that must be tested for both Linux and Windows
* `spec/type_aliases/*_spec.rb` - These are tests for manifest type aliases in `types` directory

Provider tests use fixtures from `spec/fixtures/unit`; paths must match for fixtures to load.

For types, add simple properties to the appropriate test array. Properties with extra validation or munging need dedicated test contexts.

Each class, type, provider, and fact gets its own spec file for testing.

Unit tests use [rspec-puppet](https://rspec-puppet.com/) to test Puppet catalog resources using RSpec. The facts to simulate different operating systems are provided by [facterdb](https://github.com/camptocamp/facterdb).

## Acceptance tests

Acceptance tests are functional tests that verify this module's behavior on a running system.

Test locations:

* `spec/acceptance/*_spec.rb`

The class tests are ordered with numeric prefixes to control the order they run. The custom type tests are not ordered but all come after the class tests.

Each type has its own spec file. Tests cover creating, updating, and deleting resources, with additional cases for complex behavior.

The resources `sensu_cluster_role`, `sensu_cluster_role_binding`, `sensu_role`, and `sensu_role_binding` are grouped into `sensu_rbac_resources_spec.rb` with the goal of speeding up testing times.

By default (`BEAKER_sensu_mode=base`), only class resource tests run. Other modes:

* `BEAKER_sensu_mode=types` - Run tests for all types
* `BEAKER_sensu_mode=full` - Run same tests as base but also runs more complex tests like PostgreSQL and Bolt integrations
* `BEAKER_sensu_mode=cluster` - Run cluster tests
* `BEAKER_sensu_mode=examples` - Run the test around examples in the `examples` directory

Technologies for acceptance testing:

* Docker - provides running system where configurations can be made and tests can be executed
* [serverspec](https://serverspec.org/) - Ability to test system configurations of running systems
* [beaker](https://github.com/puppetlabs/beaker) - Handles the test system setup and interfacing with Docker and serverspec
