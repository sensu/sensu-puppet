module PuppetX
  module Sensu
    module Type
      def self.name_regex
        %r{^[\w.\-:]+$}
      end

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

      # Used to take type class name and name to generate friendly error prefix
      # Puppet::Type::Sensu_asset[test] becomes Sensu_asset[test]
      def self.error_prefix(s)
        "#{s.class.to_s.split(':').last}[#{s[:name]}]:"
      end
    end
  end
end
