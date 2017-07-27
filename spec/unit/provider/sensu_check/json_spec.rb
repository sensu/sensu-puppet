require 'spec_helper'

# The goal of the let methods are to wire up a provider into a harness used for
# testing.  During Puppet runtime, there are multiple contexts a provider
# operates within.  The two primary ones are enforcement; e.g. `puppet apply`
# mode, and introspection, e.g. `puppet resource` mode.  During enforcement,
# there is an associated resource modeled in the catalog.  During introspection,
# a resource is initially absent and the provider provides information to
# initialize the resource.
#
# Terminology used in the let helper methods.
#
# "type_id" refers to the Symbol identifying the Type.  e.g. :sensu_check
#
# "resource" is an instance of Puppet::Type.type(type) as it would exist in the
# RAL during catalog application.  This resource contains the desired state
# information, the properties and parameters specified in the Puppet DSL.
#
# "provider" is an instance of the provider class being tested.  In Puppet,
# provider instances exist primarily in one of two states, either bound or not
# bound to a resource.  Provider instances are not bound when the system is
# being introspected, e.g. `puppet resource service` calls the `instances` class
# method which will instantiate provider instances which have no associated
# resource.  When applying a Puppet catalog, each provider is associated with
# exactly one resource from the Puppet DSL.
#
# Because of this dual nature, providers must be careful when accessing
# parameter data, e.g. `base_path`.  Since `base_path` is a parameter, it will
# not be accessible in the context of self.instances and `puppet resource`,
# because there is not a bound resource when discovering resources.
#
# When building a new provider with spec tests, start with `self.instances`,
# because this approach exercises a provider with the minimal amount of state.
# That is to say, the provider must be well-behaved when there is no associated
# resource.
#
# property_hash or @property_hash is an instance variable describing the current
# state of the resource as it exists on the target system.  Take care not to
# confuse this with the data contained in the resource, which describes desired
# state.
#
# property_flush or @property_flush is an instance variable used to modify the
# system from the `flush` method.  Setter methods, one for each property of the
# resource type, should modify @property_flush

type_id = :sensu_check

describe Puppet::Type.type(type_id).provider(:json) do
  let(:catalog) { Puppet::Resource::Catalog.new }
  let(:type) { Puppet::Type.type(type_id) }
  # The title of the resource, for convenience
  let(:title) { 'remote_http' }

  # The default resource hash modeling the resource in a manifest.
  let(:rsrc_hsh_base) do
    { name: title, ensure: 'present' }
  end
  # Override this helper method in nested example groups
  let(:rsrc_hsh_override) { {} }
  # Combined resource hash.  Used to initialize @provider_hash via new()
  let(:rsrc_hsh) { rsrc_hsh_base.merge(rsrc_hsh_override) }
  # A provider with @property_hash initialized, but without a resource.
  let(:bare_provider) { described_class.new(rsrc_hsh) }
  # A resource bound to bare_provider.  This has the side-effect of associating
  # the provider instance to a resource (bare_provider is no longer bare of a
  # resource.)
  let(:resource) { type.new(rsrc_hsh.merge(provider: bare_provider)) }
  # A "harnessed" provider instance suitable for testing.  @property_hash is
  # initialized and provider.resource returns a Resource.
  let(:provider) do
    resource.provider
  end

  context 'applying a catalog' do
    describe 'parameter' do
      describe '#name' do
        subject { provider.name }
        it { is_expected.to eq title }
      end
    end

    # Properties modify the system.  Parameters add supporting data.
    describe 'property' do
      # Stub out the filesystem read with fixture data
      before :each do
        expect(provider).to receive(:read_file).and_return(input)
      end

      describe '#config' do
        subject { provider.config }
        context 'with a pre-existing json file' do
          context 'containing only the check configuration itself' do
            let(:input) do
              File.read(my_fixture('mycheck_example_input.json'))
            end

            it { is_expected.to eq({}) }
          end

          context 'containing mailer plugin configuration' do
            let(:input) do
              File.read(my_fixture('mycheck_config_input.json'))
            end

            let(:expected) do
              {'mailer'=>{'mail_from'=>'sensu@example.com','mail_to'=>'monitor@example.com'}}
            end

            it { is_expected.to eq(expected) }
          end

          context 'containing configuration nested in the "checks" map' do
            let(:input) do
              File.read(my_fixture('mycheck_config_input.2.json'))
            end

            let(:expected) do
              {'checks'=>{'foo'=>'bar', 'baz'=>['q', 'u', 'x']}}
            end

            it { is_expected.to eq(expected) }
          end
        end
      end

      describe '#config=' do
        context 'with a pre-existing json file' do
          context 'without arbitrary config data' do
            # An existing JSON file the provider will modify.
            let(:input) do
              File.read(my_fixture('mycheck_example_input.json'))
            end

            valid_configs = [
              { 'foo' => 'bar' },
              { 'foo' => 'bar', 'baz' => 'qux' },
            ]

            valid_configs.each_with_index do |config, idx|
              context "and config => #{config.inspect}" do
                let(:expected_output) do
                  File.read(my_fixture("mycheck_config_output.#{idx}.json"))
                end

                let(:rsrc_hsh_override) { {config: config} }

                it 'writes a JSON file to the filesystem' do
                  # TODO: Would be nice to make this a shared expectation
                  expect(provider).to receive(:write_json_object) do |fp, obj|
                    expect(fp).to eq(provider.config_file)
                    ex_out = JSON.parse(expected_output)
                    check_map = ex_out['checks']['remote_http']
                    # This gives a nice diff if there is an issue
                    expect(obj['checks']['remote_http']).to eq(check_map)
                    # This tests the complete configuration
                    expect(obj).to eq(ex_out)
                  end

                  provider.config = config
                  provider.flush
                end

                it 'writes sorted JSON output' do
                  expect(described_class).to receive(:write_output) do |_, data|
                    # Trailing newlines must match to get a nice diff
                    # See: https://github.com/rspec/rspec-support/issues/70
                    expect(data).to eq(expected_output.chomp)
                  end
                  provider.config = config
                  provider.flush
                end
              end
            end
          end

          context 'with arbitrary config data' do
            # An existing JSON file the provider will modify.
            let(:input) do
              File.read(my_fixture('mycheck_config_input.json'))
            end

            valid_configs = [
              { 'foo' => 'bar' },
              { 'foo' => 'bar', 'baz' => 'qux' },
            ]

            valid_configs.each_with_index do |config, idx|
              context "and config => #{config.inspect}" do
                let(:expected_output) do
                  File.read(my_fixture("mycheck_config_output.#{idx}.json"))
                end

                let(:rsrc_hsh_override) { {config: config} }

                it 'writes a JSON file to the filesystem' do
                  # TODO: Would be nice to make this a shared expectation
                  expect(provider).to receive(:write_json_object) do |fp, obj|
                    expect(fp).to eq(provider.config_file)
                    ex_out = JSON.parse(expected_output)
                    check_map = ex_out['checks']['remote_http']
                    # This gives a nice diff if there is an issue
                    expect(obj['checks']['remote_http']).to eq(check_map)
                    # This tests the complete configuration
                    expect(obj).to eq(ex_out)
                  end

                  provider.config = config
                  provider.flush
                end

                it 'writes sorted JSON output' do
                  expect(described_class).to receive(:write_output) do |_, data|
                    # Trailing newlines must match to get a nice diff
                    # See: https://github.com/rspec/rspec-support/issues/70
                    expect(data).to eq(expected_output.chomp)
                  end
                  provider.config = config
                  provider.flush
                end
              end
            end

            # TODO: Test what happens when the provider value is not specified.
            context 'and config => undef' do
              xit 'preserves the existing arbitrary config'
            end
          end
        end
      end

      describe '#custom' do
        context 'with a pre-existing check definition' do
          # An existing JSON file the provider will modify.
          let(:input) do
            File.read(my_fixture('mycheck_example_input.json'))
          end
          # Stub out the filesystem read with fixture data
          before :each do
            allow(provider).to receive(:read_file).and_return(input)
          end

          subject { provider.custom }

          context 'without custom configuration' do
            it { is_expected.to eq({}) }
          end
          context 'with custom configuration' do
            let(:input) do
              File.read(my_fixture('mycheck_custom_input.json'))
            end
            it { is_expected.to eq({'foo' => 'bar'}) }
          end
        end
      end

      describe '#custom=' do
        context 'with a pre-existing json file' do
          # An existing JSON file the provider will modify.
          let(:input) do
            File.read(my_fixture('mycheck_example_input.json'))
          end

          let(:expected_output) do
            File.read(my_fixture('mycheck_expected_output.json'))
          end

          context 'with custom defined' do
            # Example value for the custom property from the README
            let(:custom) do
              {
                'foo'      => 'bar',
                'numval'   => 6,
                'boolval'  => true,
                'in_array' => ['foo','baz'],
              }
            end

            # The desired state from the catalog
            let(:rsrc_hsh_override) { {custom: custom} }

            it 'writes the configuration file as a JSON object' do
              # TODO: Would be nice to make this a shared expectation
              expect(provider).to receive(:write_json_object) do |fp, obj|
                expect(fp).to eq(provider.config_file)
                ex_out = JSON.parse(expected_output)
                check_def = ex_out['checks']['remote_http']
                # This gives a nice diff if there is an issue
                expect(obj['checks']['remote_http']).to eq(check_def)
                # This tests the complete configuration
                expect(obj).to eq(ex_out)
              end

              provider.custom = custom
              provider.flush
            end
          end

          context 'with unsorted input JSON' do
            let(:input) do
              File.read(my_fixture('mycheck_unsorted_input.json'))
            end
            it 'writes sorted JSON output' do
              expect(described_class).to receive(:write_output) do |_, data|
                # Trailing newlines must match to get a nice diff
                # See: https://github.com/rspec/rspec-support/issues/70
                expect(data).to eq(expected_output.chomp)
              end
              provider.flush
            end
          end
        end
      end
    end
  end
end
