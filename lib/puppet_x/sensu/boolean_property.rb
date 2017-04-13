module PuppetX
  module Sensu
    class BooleanProperty < Puppet::Property
      @values_for_true = [true, :true, 'true', :yes, 'yes']
      @values_for_false = [false, :false, 'false', :no, 'no']

      class << self
        attr_reader :values_for_true, :values_for_false
      end

      # normalize to :true and :false
      # true/false (boolean) cannot be used because if the should value of a
      # property is false, puppet will take the purperty as unmanaged and will
      # not even check if it's in sync
      def unsafe_munge(value)
        # downcase strings
        if value.respond_to? :downcase
          value = value.downcase
        end

        case value
          when *BooleanProperty.values_for_true
            :true
          when *BooleanProperty.values_for_false
            :false
          when :absent, 'absent'
            :absent
          else
            fail "expected a boolean value, got #{value.inspect}"
        end
      end

      # allow the provider to work with real booleans
      def set(value)
        super(value.to_s == 'absent' ? :absent : value == :true)
      end

      def retrieve
        s = super
        case s
          when true
            :true
          when false
            :false
          else
            s
        end
      end
    end
  end
end
