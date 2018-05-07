module PuppetX
  module Sensu
    module Type

      def add_properties_and_params
        ensurable

        newproperty(:custom, :parent => PuppetX::Sensu::HashProperty) do
          desc "Custom variables"
          defaultto {}
        end
      end

      def add_autorequires
        autorequire(:package) do
          ['sensu-cli']
        end

        autorequire(:service) do
          ['sensu-backend']
        end

        autorequire(:exec) do
          ['sensuctl_configure']
        end

        autorequire(:sensu_api_validator) do
          requires = []
          catalog.resources.each do |resource|
            if resource.class.to_s == 'Puppet::Type::Sensu_api_validator'
              requires << resource.name
            end
          end
          requires
        end
      end
    end
  end
end
