module PuppetX
  module Sensu
    class ArrayProperty < Puppet::Property

      def should
        if @should and @should[0] == :absent
          :absent
        else
          @should
        end
      end

      def insync?(is)
        return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
        is == should
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

