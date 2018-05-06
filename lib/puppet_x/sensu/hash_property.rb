module PuppetX
  module Sensu
    class HashProperty < Puppet::Property
      validate do |value|
        fail "#{self.name.to_s} should be a Hash" unless value.is_a? ::Hash
      end
    end
  end
end

