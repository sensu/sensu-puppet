module PuppetX
  module Sensu
    module AgentEntityConfig
      def self.config_classes
        {
          'subscriptions' => [],
          'labels'        => {},
          'annotations'   => {},
          'redact'        => [],
        }
      end
      def self.metadata_configs
        [ 'labels', 'annotations' ]
      end
    end
  end
end
