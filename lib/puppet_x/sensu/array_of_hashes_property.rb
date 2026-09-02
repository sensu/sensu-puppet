module PuppetX
  module Sensu
    class ArrayOfHashesProperty < Puppet::Property
      def insync?(is)
        return super(is) unless is.is_a?(Array) && should.is_a?(Array)
        strip_nils = lambda { |h| h.is_a?(Hash) ? h.reject { |_, v| v.nil? } : h }
        is.map(&strip_nils) == should.map(&strip_nils)
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

