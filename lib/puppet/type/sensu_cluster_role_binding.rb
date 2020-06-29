require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_cluster_role_binding) do
  desc <<-DESC
@summary Manages Sensu cluster role bindings
@example Add a cluster role binding
  sensu_cluster_role_binding { 'test':
    ensure   => 'present',
    role_ref => {'type' => 'ClusterRole', 'name' => 'test-role'},
    subjects => [
      { 'type' => 'User', 'name' => 'test-user' }
    ], 
  }

@example Add a cluster role binding for a Role
  sensu_cluster_role_binding { 'test':
    ensure   => 'present',
    role_ref => {'type' => 'Role', 'name' => 'test-role'},
    subjects => [
      { 'type' => 'User', 'name' => 'test-user' }
    ],
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_cluster_role` - Puppet will autorequire `sensu_cluster_role` resource defined in `role_ref` property.
* `sensu_user` - Puppet will autorequire `sensu_user` resources based on users and groups defined for the `subjects` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the role binding."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_cluster_role_binding name invalid"
      end
    end
  end

  newproperty(:role_ref, :parent => PuppetX::Sensu::HashProperty) do
    desc "References a role in the current namespace or a cluster role."
    validate do |value|
      super(value)
      if value.keys.sort != ["name","type"]
        raise ArgumentError, "role_ref must only contain keys of 'name' and 'type'"
      end
      if ! ["Role","ClusterRole"].include?(value["type"])
        raise ArgumentError, "role_ref 'type' must be either 'Role' or 'ClusterRole'"
      end
    end
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

  autorequire(:sensu_cluster_role) do
    roles = []
    if self[:role_ref] && self[:role_ref]["type"] == 'ClusterRole'
      catalog.resources.each do |resource|
        if resource.class.to_s == "Puppet::Type::Sensu_cluster_role"
          if resource.name == self[:role_ref]["name"]
            roles << resource.name
          end
        end
      end
    end
    roles
  end

  autorequire(:sensu_role) do
    roles = []
    if self[:role_ref] && self[:role_ref]["type"] == 'Role'
      catalog.resources.each do |resource|
        if resource.class.to_s == "Puppet::Type::Sensu_role"
          if resource[:resource_name] == self[:role_ref]["name"]
            roles << resource[:resource_name]
          end
        end
      end
    end
    roles
  end

  autorequire(:sensu_user) do
    users = ['admin']
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
