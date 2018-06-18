module PuppetX
  module Sensu
    class IntegerProperty < Puppet::Property
      validate do |value|
        unless value.to_s =~ /^[-]?\d+$/ or value.to_s == 'absent'
          raise ArgumentError, "#{self.name.to_s} should be an Integer"
        end
      end
      munge do |value|
        value.to_s == 'absent' ? :absent : value.to_i
      end
    end
  end
end

