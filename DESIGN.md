# Module Design

## Classes

There are seven main public classes and other can be added if they need to be managed separately than the existing classes:

* sensu - Define variables used by all other classes
* sensu::agent - Sensu Agent
* sensu::backend - Sensu Backend
* sensu::cli - Manage sensuctl
* sensu::api - Configure sensu_api providers
* sensu::resources - Define sensu resources
* sensu::plugins - Sensu plugins

The class `sensu::common` is a private class that holds resources shared by many public classes.

Subclasses to the above hold resources for that resources to keep the logic in the main public class shorter. So `sensu::backend::default_resources` is a private classes that adds functionality to `sensu::backend`. There are also some shared classes like `sensu::ssl` that are private and have resources shared by other public classes.

If a parameter is used by multiple public classes, it belongs in `sensu` class. All other parameters should be added to the appropriate public class.

## Types/Provides

### Sensuctl types

The types to `sensuctl` resources are designed to closely match the resource specifications from Sensu Go. For example the Sensu Go `check` resource property of `interval` would map directly to the `sensu_check` type property of `interval`.

Keys in the Sensu Go specification under `spec` should have a 1-to-1 mapping with Puppet type properties.

The exception to the 1-to-1 mapping is Sensu Go resource `metadata`. The values for `metadata` keys of `name`, `namespace`, `labels`, and `annotations` are pulled out into Puppet type properties. The metadata exception is to properly handle resource names and namespaces and relationships as well as the composite names used by namespace capable resources.

### All other types/providers

Other types and providers are added where possible to avoid the use of complex Exec resources in the manifest code.
One example is `sensu_plugin` which manages Sensu Go plugins that does not use `sensuctl`.

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
* `error_prefix` - Helper function to produce meaning full string used with error messages in this module's types.

## Unit tests

The unit tests are designed to check Puppet catalog behavior without ensuring the functionality on a running system.

Test locations:

* `spec/classes` - Theses for each class in `manifests` directory.
* `spec/unit/*_spec.rb` - These are tests for the types defined in `lib/puppet/types`
* `spec/unit/provider/**/*_spec.rb` - These are tests for the providers defined in `lib/puppet/providers`
* `spec/unit/facter/*_spec.rb` - These are tests for custom facts that must be tested for both Linux and Windows
* `spec/type_aliases/*_spec.rb` - These are tests for manifest type aliases in `types` directory

The unit tests for providers rely on fixtures in `spec/fixtures/unit` and the path matters in order for fixtures to be loaded. 

For types the simple properties can be added to appropariate array for testing behavior of the property. Any properties with extra validations or munging will require their own context and tests.

Each class, type, provider, and fact gets its own spec file for testing.

Unit tests use [rspec-puppet](https://rspec-puppet.com/) to test Puppet catalog resources using RSpec. The facts to simulate different operating systems are provided by [facterdb](https://github.com/camptocamp/facterdb).

## Acceptance tests

The acceptance tests functional tests to ensure this module's behavior on a running system.

Test locations:

* `spec/acceptance/*_spec.rb`

The class tests are ordered with numeric prefixes to control the order they run. The custom type tests are not ordered but all come after the class tests.

The type of `sensu_check` will have its tests in `sensu_check_spec.rb`. The tests to run are adding resources, updating resources, and deleting resources. Some extra test cases should be added based on any complexities of a given type.

The resources `sensu_cluster_role`, `sensu_cluster_role_binding`, `sensu_role`, and `sensu_role_binding` are grouped into `sensu_rbac_resources_spec.rb` with the goal of speeding up testing times.

By default only tests for class resources run which is the same as setting the enviornment variable `BEAKER_sensu_mode=base`.  The other possible modes are the following:

* `BEAKER_sensu_mode=types` - Run tests for all types
* `BEAKER_sensu_mode=full` - Run same tests as base but also runs more complex tests like PostgreSQL and Bolt integrations
* `BEAKER_sensu_mode=cluster` - Run cluster tests
* `BEAKER_sensu_mode=examples` - Run the test around examples in the `examples` directory

Technologies for acceptance testing:

* Docker - provides running system where configurations can be made and tests can be executed
* [serverspec](https://serverspec.org/) - Ability to test system configurations of running systems
* [beaker](https://github.com/puppetlabs/beaker) - Handles the test system setup and interfacing with Docker and serverspec
