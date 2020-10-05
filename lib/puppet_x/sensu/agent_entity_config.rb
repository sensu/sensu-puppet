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

      def self.check_redacted(entity)
        metadata = entity.fetch('metadata', {})
        labels = metadata.fetch('labels', {})
        annotations = metadata.fetch('annotations', {})
        (labels || {}).each_pair do |key,value|
          return true if value == 'REDACTED'
        end
        (annotations || {}).each_pair do |key,value|
          return true if value == 'REDACTED'
        end
        return false
      end
    end
  end
end
