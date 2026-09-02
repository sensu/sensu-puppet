require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/hash_property'

SENSU_PIPELINE_VALIDATE_REF = lambda do |ref, field_name|
  unless ref.is_a?(Hash)
    raise ArgumentError, "workflows #{field_name} must be a Hash"
  end
  %w[name type api_version].each do |key|
    unless ref.key?(key)
      raise ArgumentError, "workflows #{field_name} must have a '#{key}' key"
    end
    unless ref[key].is_a?(String) && !ref[key].empty?
      raise ArgumentError, "workflows #{field_name} '#{key}' must be a non-empty String"
    end
  end
  valid_keys = %w[name type api_version]
  ref.keys.each do |k|
    raise ArgumentError, "#{k} is not a valid key for workflows #{field_name}" unless valid_keys.include?(k.to_s)
  end
end

Puppet::Type.newtype(:sensu_pipeline) do
  desc <<-DESC
@summary Manages Sensu pipelines
@example Create a pipeline
  sensu_pipeline { 'test':
    ensure    => 'present',
    workflows => [
      {
        'name'    => 'notify',
        'filters' => [{ 'name' => 'is_incident', 'type' => 'EventFilter', 'api_version' => 'core/v2' }],
        'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
      },
    ],
  }

@example Create a pipeline in namespace `dev`
  sensu_pipeline { 'test in dev':
    ensure    => 'present',
    workflows => [
      {
        'name'    => 'notify',
        'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
      },
    ],
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the pipeline.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the pipeline."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_pipeline name invalid"
      end
    end
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:workflows, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc <<-EOS
    One or more pipeline workflows.
    Each workflow is a Hash with the following keys:
    * name - Required String - descriptive name for the workflow
    * filters - Optional Array of ResourceReference Hashes, each with keys: name, type, api_version
    * mutator - Optional ResourceReference Hash with keys: name, type, api_version
    * handler - Required ResourceReference Hash with keys: name, type, api_version

    Example:
      [
        {
          'name'    => 'notify',
          'filters' => [{ 'name' => 'is_incident', 'type' => 'EventFilter', 'api_version' => 'core/v2' }],
          'mutator' => { 'name' => 'only_check_output', 'type' => 'Mutator', 'api_version' => 'core/v2' },
          'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
        },
      ]
    EOS
    validate do |value|
      unless value.is_a?(Hash)
        raise ArgumentError, "workflows elements must be a Hash"
      end
      unless value.key?('name')
        raise ArgumentError, "workflows element must have a 'name' key"
      end
      unless value['name'].is_a?(String) && !value['name'].empty?
        raise ArgumentError, "workflows element 'name' must be a non-empty String"
      end
      unless value.key?('handler')
        raise ArgumentError, "workflows element must have a 'handler' key"
      end
      SENSU_PIPELINE_VALIDATE_REF.call(value['handler'], 'handler')
      if value.key?('filters')
        unless value['filters'].is_a?(Array)
          raise ArgumentError, "workflows element 'filters' must be an Array"
        end
        value['filters'].each do |f|
          SENSU_PIPELINE_VALIDATE_REF.call(f, 'filters element')
        end
      end
      if value.key?('mutator')
        SENSU_PIPELINE_VALIDATE_REF.call(value['mutator'], 'mutator')
      end
      valid_keys = %w[name filters mutator handler]
      value.keys.each do |k|
        raise ArgumentError, "#{k} is not a valid key for a workflow" unless valid_keys.include?(k.to_s)
      end
    end
  end

  newproperty(:continue_on_error, :boolean => true) do
    desc "If true, the pipeline continues executing workflows when an error occurs."
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this pipeline belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
  end

  def self.title_patterns
    [
      [
        /^((\S+) in (\S+))$/,
        [
          [:name],
          [:resource_name],
          [:namespace],
        ],
      ],
      [
        /(.*)/,
        [
          [:name],
        ],
      ],
    ]
  end

  def pre_run_check
    required_properties = [
      :workflows,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && (self[property].nil? || self[property] == [:absent])
        fail "You must provide a #{property}"
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end

end
