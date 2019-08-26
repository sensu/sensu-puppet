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
        catalog_namespaces = []
        resource.catalog.resources.each do |catalog_resource|
          if catalog_resource.class.to_s == 'Puppet::Type::Sensu_namespace'
            catalog_namespaces << catalog_resource.name
          end
        end
        namespaces = resource.provider.namespaces()
        if (resource[:ensure] && resource[:ensure].to_sym != :absent) && !( catalog_namespaces.include?(resource[:namespace]) || namespaces.include?(resource[:namespace]) )
          raise Puppet::Error, "Sensu namespace '#{resource[:namespace]}' must be defined or exist"
        end
      end
    end
  end
end
