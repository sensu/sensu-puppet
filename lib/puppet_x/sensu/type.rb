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
    end
  end
end
