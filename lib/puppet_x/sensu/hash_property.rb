module PuppetX
  module Sensu
    class HashProperty < Puppet::Property
      validate do |value|
        fail "#{self.name.to_s} should be a Hash" unless value.is_a? ::Hash
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

