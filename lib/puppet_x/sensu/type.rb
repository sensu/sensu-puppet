module PuppetX
  module Sensu
    module Type

      def add_autorequires(require_configure=true)
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
          requires = []
          catalog.resources.each do |resource|
            if resource.class.to_s == 'Puppet::Type::Sensu_api_validator'
              requires << resource.name if resource.name == 'sensu'
            end
          end
          requires
        end
      end
    end
  end
end
