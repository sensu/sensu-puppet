module Puppet_X
  module Sensu
    module Totype
      def to_type(value)
        if value.is_a?(Hash)
          new = Hash.new
          value.each { |k,v| new[k] = to_type v }
          new
        elsif value.is_a?(Array)
          value.collect { |v| to_type v }
        else
          case value
          when true, 'true', 'True', :true
            true
          when false, 'false', 'False', :false
            false
          when /^([0-9])+$/
            value.to_i
          else
            value
          end
        end
      end
    end
  end
end

