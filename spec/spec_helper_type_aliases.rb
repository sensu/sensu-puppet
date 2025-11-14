require 'spec_helper'

# Type alias testing requires special setup
RSpec.configure do |config|
  config.before(:each) do
    # Set the module path to include our fixtures
    fixture_modules = File.join(File.dirname(__FILE__), 'fixtures', 'modules')
    if Dir.exist?(fixture_modules)
      # Set Puppet settings for module resolution
      Puppet.settings[:modulepath] = fixture_modules
      
      # Reset the current environment to ensure fresh module loading
      Puppet.push_context(environment: nil)
      env = Puppet.lookup(:current_environment)
      if env
        env.instance_variable_set(:@modulepath, [fixture_modules])
      end
    end
  end
end

# Type alias validation helper
def validate_type_alias(type_name, value)
  begin
    # Load the type alias from the current module
    type_alias = Puppet::Pops::Types::TypeFactory.type_of_value(value)
    type_definition = Puppet::Pops::Types::TypeParser.singleton.parse(type_name)
    type_definition.instance?(value)
  rescue => e
    false
  end
end