module PuppetX
  module Sensu
    module Type

      def add_autorequires(namespace=true, require_configure=true)
        autorequire(:package) do
          ['sensu-go-cli']
        end

        autorequire(:service) do
          ['sensu-backend']
        end

        if require_configure
          autorequire(:sensu_configure) do
            ['puppet']
          end
        end

        autorequire(:sensu_api_validator) do
          [ 'sensu' ]
        end

        if namespace
          autorequire(:sensu_namespace) do
            [ self[:namespace] ]
          end
        end
      end

      def self.validate_namespace(resource)
        namespaces = []
        resource.catalog.resources.each do |catalog_resource|
          if catalog_resource.class.to_s == 'Puppet::Type::Sensu_namespace'
            namespaces << catalog_resource.name
          end
        end
        if resource[:ensure].to_sym != :absent && ! namespaces.include?(resource[:namespace])
          raise Puppet::Error, "Sensu namespace '#{resource[:namespace]}' must be defined"
        end
      end
    end
  end
end
