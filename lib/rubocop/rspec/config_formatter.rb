# frozen_string_literal: true

require 'yaml'

module RuboCop
  module RSpec
    # Builds a YAML config file from two config hashes
    class ConfigFormatter
      EXTENSION_ROOT_DEPARTMENT = %r{^(RSpec/)}.freeze
      SUBDEPARTMENTS = [].freeze
      AMENDMENTS = %(Metrics/BlockLength)
      COP_DOC_BASE_URL = 'https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/'

      def initialize(config, descriptions)
        @config       = config
        @descriptions = descriptions
      end

      def dump
        YAML.dump(unified_config)
          .gsub(EXTENSION_ROOT_DEPARTMENT, "\n\\1")
          .gsub(*AMENDMENTS, "\n\\0")
          .gsub(/^(\s+)- /, '\1  - ')
          .gsub('"~"', '~')
      end

      private

      def unified_config
        cops.each_with_object(config.dup) do |cop, unified|
          next if SUBDEPARTMENTS.include?(cop) || AMENDMENTS.include?(cop)

          replace_nil(unified[cop])
          unified[cop].merge!(descriptions.fetch(cop))
          unified[cop]['Reference'] = reference(cop)
        end
      end

      def cops
        (descriptions.keys | config.keys).grep(EXTENSION_ROOT_DEPARTMENT)
      end

      def replace_nil(config)
        config.each do |key, value|
          config[key] = '~' if value.nil?
        end
      end

      def reference(cop)
        COP_DOC_BASE_URL + cop
      end

      attr_reader :config, :descriptions
    end
  end
end
