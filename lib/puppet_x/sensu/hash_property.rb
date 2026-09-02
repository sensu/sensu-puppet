module PuppetX
  module Sensu
    class HashProperty < Puppet::Property
      validate do |value|
        fail "#{self.name.to_s} should be a Hash" unless value.is_a? ::Hash
        value.each_pair do |key, _val|
          fail "#{self.name.to_s} key #{key} must be a String" unless key.is_a?(String) || key.is_a?(Symbol)
          fail "#{self.name.to_s} key #{key} must not be empty" if key.to_s.empty?
        end
      end

      munge do |value|
        value.transform_keys(&:to_s)
      end

      def insync?(is)
        ignore_labels = ['sensu.io/managed_by']
        if self.name == :labels && is.is_a?(Hash)
          is = is.reject { |k, _| ignore_labels.include?(k) }
        end
        super(is)
      end

      def change_to_s(currentvalue, newvalue)
        currentvalue = currentvalue.to_s if currentvalue != :absent
        newvalue = newvalue.to_s
        super(currentvalue, newvalue)
      end

      def is_to_s(currentvalue)
        currentvalue.to_s
      end
      alias :should_to_s :is_to_s
    end
  end
end
