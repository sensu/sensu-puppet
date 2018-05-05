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
    end
  end
end

