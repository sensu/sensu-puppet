require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_role_binding) do
  desc <<-DESC
@summary Manages Sensu role bindings
@example Add a role binding
  sensu_role_binding { 'test':
    ensure   => 'present',
    role_ref => 'test-role',
    subjects => [
      { 'type' => 'User', 'name' => 'test-user' }
    ], 
  }

**Autorequires**:
* `Package[sensu-cli]`
* `Service[sensu-backend]`
* `Sensu_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `sensu_role` - Puppet will autorequire `sensu_role` resource defined in `role_ref` property.
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
* `sensu_user` - Puppet will autorequire `sensu_user` resources based on users and groups defined for the `subjects` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the role binding."
  end

  newproperty(:namespace) do
    desc "Namespace the role binding is restricted to."
    defaultto 'default'
  end

  newproperty(:role_ref) do
    desc "References a role."
  end

  newproperty(:subjects, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc "The users or groups being assigned."
    validate do |subject|
      if ! subject.is_a?(Hash)
        raise ArgumentError, "Each subject must be a Hash not #{subject.class}"
      end
      required_keys = ['name','type']
      subject_keys = subject.keys.map { |k| k.to_s }
      required_keys.each do |k|
        if ! subject_keys.include?(k)
          raise ArgumentError, "subject requires key #{k}"
        end
      end
      subject_keys.each do |k|
        if ! required_keys.include?(k)
          raise ArgumentError, "#{k} is not a valid subject key"
        end
      end
      valid_types = ['User','Group']
      type = subject[:type] || subject['type']
      if ! valid_types.include?(type)
        raise ArgumentError, "#{type} is not a valid type"
      end
    end
  end

  autorequire(:sensu_role) do
    [ self[:role_ref] ]
  end

  autorequire(:sensu_user) do
    users = []
    groups = []
    (self[:subjects] || []).each do |subject|
      if subject['type'] == 'User'
        users << subject['name']
      end
      if subject['type'] == 'Group'
        groups << subject['name']
      end
    end
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Sensu_user'
        (resource[:groups] || []).each do |group|
          if groups.include?(group)
            users << resource.name
          end
        end
      end
    end
    users
  end

  validate do
    required_properties = [
      :role_ref,
      :subjects,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
