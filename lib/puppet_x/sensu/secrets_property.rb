module PuppetX
  module Sensu
    class SecretsProperty < Puppet::Property
      validate do |value|
        if ! value.is_a?(Hash)
          raise ArgumentError, "secrets elements must be a Hash"
        end
        required_keys = ['name','secret']
        value.keys.each do |key|
          if ! required_keys.include?(key)
            raise ArgumentError, "#{key} is not a valid key for secrets"
          end
        end
        required_keys.each do |key|
          if ! value.key?(key)
            raise ArgumentError, "#{key} is required for secrets"
          end
        end
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

