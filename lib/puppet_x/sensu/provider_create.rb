module PuppetX
  module Sensu
    module ProviderCreate
      def create
        fail 'pre_create not defined' unless respond_to? :pre_create
        pre_create
        resource.properties.each do |prop|
          next if prop.name == :ensure # we're being called because we're syncing ensure
          prop.set(prop.should) unless prop.should.nil?
        end
      end
    end
  end
end
