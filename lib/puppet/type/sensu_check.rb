require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.newtype(:sensu_check) do
  @doc = "Manages Sensu checks"

  class SensuCheckArrayProperty < Puppet::Property

    def should
      if @should and @should[0] == :absent
        :absent
      else
        @should
      end
    end

  end

  def initialize(*args)
    super *args

    if c = catalog
      self[:notify] = [
        "Service[sensu-client]",
        "Service[sensu-server]",
        "Service[sensu-enterprise]",
        "Service[sensu-api]",
      ].select { |ref| c.resource(ref) }
    end
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    desc "The name of the check."
  end

  newproperty(:command) do
    desc "Command to be run by the check"
    newvalues(/.*/, :absent)
  end

  newproperty(:dependencies, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "Dependencies of this check"
    newvalues(/.*/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:handlers, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "List of handlers that responds to this check"
    newvalues(/.*/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:contacts, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "Contact names to override handler configuration via Contact Routing"
    # Valid names documented at
    # https://sensuapp.org/docs/0.29/enterprise/contact-routing.html#contact-names
    newvalues(/^[\w\.-]+$/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:high_flap_threshold) do
    desc "A host is determined to be flapping when the percent change exceedes this threshold."
    newvalues(/.*/, :absent)
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:cron) do
    desc 'When the check should be executed, using the Cron syntax.'
    newvalues(/.*/, :absent)
  end

  newproperty(:interval) do
    desc "How frequently the check runs in seconds"
    newvalues(/.*/, :absent)
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:occurrences) do
    desc "The number of event occurrences before the handler should take action."
    newvalues(/.*/, :absent)
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:refresh) do
    desc "The number of seconds sensu-plugin-aware handlers should wait before taking second action."
    newvalues(/.*/, :absent)
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/checks'
  end

  newproperty(:low_flap_threshold) do
    desc "A host is determined to be flapping when the percent change is below this threshold."
    newvalues(/.*/, :absent)
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:source) do
    desc "The check source, used to create a JIT Sensu client for an external resource (e.g. a network switch)."
    newvalues(/.*/, :absent)
  end

  newproperty(:subscribers, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "Who is subscribed to this check"
    newvalues(/.*/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:custom) do
    desc "Custom check variables"
    include PuppetX::Sensu::ToType

    def is_to_s(hash = @is)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def should_to_s(hash = @should)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def insync?(is)
      if defined? @should[0]
        if is == @should[0].each { |k, v| value[k] = to_type(v) }
          true
        else
          false
        end
      else
        true
      end
    end

    defaultto {}
  end

  newproperty(:type) do
    desc "What type of check is this"
    newvalues(/.*/, :absent)
  end

  newproperty(:standalone, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Whether this is a standalone check"
    newvalues(/.*/, :absent)
  end

  newproperty(:timeout) do
    desc "Check timeout in seconds, after it fails"
    newvalues(/.*/, :absent)
    munge do |value|
      return :absent if value.to_s == 'absent'
      i, f = value.to_i, value.to_f
      i == f ? i : f
    end
  end

  newproperty(:aggregate) do
    desc "Whether check is aggregate"
    newvalues(/.*/, :absent)
    munge do |value|
      return :absent if value.to_s == 'absent'
      case value
      when true, 'true', 'True', :true, 1
        true
      when false, 'false', 'False', :false, 0
        false
      else
        value
      end
    end
  end

  newproperty(:aggregates, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "An array of aggregates to add to the check"
    newvalues(/.*/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:handle, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Whether check event send to a handler"
    newvalues(/.*/, :absent)
  end

  newproperty(:publish, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Whether check is unpublished"
    newvalues(/.*/, :absent)
  end

  newproperty(:subdue) do
    desc "Check subdue"
    newvalues(/.*/, :absent)
  end

  newproperty(:proxy_requests) do
    desc "Proxy Requests"
    newvalues(/.*/, :absent)
  end

  newproperty(:ttl) do
    desc "Check ttl in seconds"
    newvalues(/.*/, :absent)
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  autorequire(:package) do
    ['sensu']
  end
end
