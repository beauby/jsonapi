require 'jsonapi/validator/exceptions'

module JSONAPI
  module Validator
    class Document
      TOP_LEVEL_KEYS = %w(data errors meta).freeze
      EXTENDED_TOP_LEVEL_KEYS = (TOP_LEVEL_KEYS +
                                 %w(jsonapi links included)).freeze
      RESOURCE_KEYS = %w(id type attributes relationships links meta).freeze
      RESOURCE_IDENTIFIER_KEYS = %w(id type).freeze
      EXTENDED_RESOURCE_IDENTIFIER_KEYS = (RESOURCE_IDENTIFIER_KEYS +
                                           %w(meta)).freeze
      RELATIONSHIP_KEYS = %w(data links meta).freeze
      RELATIONSHIP_LINK_KEYS = %w(self related).freeze
      JSONAPI_OBJECT_KEYS = %w(version meta).freeze

      # Validate the structure of a JSON API document.
      #
      # @param [Hash] document The input JSONAPI document.
      # @raise [JSONAPI::Validator::InvalidDocument] if document is invalid.
      def self.validate!(document)
        ensure!(document.is_a?(Hash),
                'A JSON object MUST be at the root of every JSON API request ' \
                'and response containing data.')
        unexpected_keys = document.keys - EXTENDED_TOP_LEVEL_KEYS
        ensure!(unexpected_keys.empty?,
                "Unexpected members at top level: #{unexpected_keys}.")
        ensure!(!(document.keys & TOP_LEVEL_KEYS).empty?,
                "A document MUST contain at least one of #{TOP_LEVEL_KEYS}.")
        ensure!(!(document.key?('data') && document.key?('errors')),
                'The members data and errors MUST NOT coexist in the same ' \
                'document.')
        ensure!(document.key?('data') || !document.key?('included'),
                'If a document does not contain a top-level data key, the ' \
                'included member MUST NOT be present either.')
        validate_data!(document['data']) if document.key?('data')
        validate_errors!(document['errors']) if document.key?('errors')
        validate_meta!(document['meta']) if document.key?('meta')
        validate_jsonapi!(document['jsonapi']) if document.key?('jsonapi')
        validate_included!(document['included']) if document.key?('included')
        validate_links!(document['links']) if document.key?('links')
      end

      # @api private
      def self.validate_data!(data)
        if data.is_a?(Hash)
          validate_primary_resource!(data)
        elsif data.is_a?(Array)
          data.each { |res| validate_resource!(res) }
        elsif data.nil?
        # Do nothing
        else
          ensure!(false,
                  'Primary data must be either nil, an object or an array.')
        end
      end

      # @api private
      def self.validate_primary_resource!(res)
        ensure!(res.is_a?(Hash), 'A resource object must be an object.')
        ensure!(res.key?('type'), 'A resource object must have a type.')
        unexpected_keys = res.keys - RESOURCE_KEYS
        ensure!(unexpected_keys.empty?,
                "Unexpected members for primary resource: #{unexpected_keys}")
        validate_attributes!(res['attributes']) if res.key?('attributes')
        validate_relationships!(res['relationships']) if res.key?('relationships')
        validate_links!(res['links']) if res.key?('links')
        validate_meta!(res['meta']) if res.key?('meta')
      end

      # @api private
      def self.validate_resource!(res)
        validate_primary_resource!(res)
        ensure!(res.key?('id'), 'A resource object must have an id.')
      end

      # @api private
      def self.validate_attributes!(attrs)
        ensure!(attrs.is_a?(Hash), 'The value of the attributes key MUST be an ' \
                                   'object.')
      end

      # @api private
      def self.validate_relationships!(rels)
        ensure!(rels.is_a?(Hash), 'The value of the relationships key MUST be ' \
                                  'an object')
        rels.values.each { |rel| validate_relationship!(rel) }
      end

      # @api private
      def self.validate_relationship!(rel)
        ensure!(rel.is_a?(Hash), 'A relationship object must be an object.')
        unexpected_keys = rel.keys - RELATIONSHIP_KEYS
        ensure!(unexpected_keys.empty?, 'Unexpected members for relationship: ' \
                                        "#{unexpected_keys}")
        ensure!(!rel.keys.empty?, 'A relationship object MUST contain at least '\
                                  "one of #{RELATIONSHIP_KEYS}")
        validate_relationship_data!(rel['data']) if rel.key?('data')
        validate_relationship_links!(rel['links']) if rel.key?('links')
        validate_meta!(rel['meta']) if rel.key?('meta')
      end

      # @api private
      def self.validate_relationship_data!(data)
        if data.is_a?(Hash)
          validate_resource_identifier!(data)
        elsif data.is_a?(Array)
          data.each { |ri| validate_resource_identifier!(ri) }
        elsif data.nil?
        # Do nothing
        else
          ensure!(false, 'Relationship data must be either nil, an object or ' \
                         'an array.')
        end
      end

      # @api private
      def self.validate_resource_identifier!(ri)
        ensure!(ri.is_a?(Hash), 'A resource identifier object must be an object')
        unexpected_keys = ri.keys - EXTENDED_RESOURCE_IDENTIFIER_KEYS
        ensure!(unexpected_keys.empty?, 'Unexpected members for resource ' \
                                        "identifier: #{unexpected_keys}.")
        ensure!(ri.keys & RESOURCE_IDENTIFIER_KEYS != RESOURCE_IDENTIFIER_KEYS,
                'A resource identifier object MUST contain ' \
                "#{RESOURCE_IDENTIFIER_KEYS} members.")
        ensure!(ri['id'].is_a?(String), 'Member id must be a string.')
        ensure!(ri['type'].is_a?(String), 'Member type must be a string.')
        validate_meta!(ri['meta']) if ri.key?('meta')
      end

      # @api private
      def self.validate_relationship_links!(links)
        validate_links!(links)
        ensure!(!(links.keys & RELATIONSHIP_LINK_KEYS).empty?,
                'A relationship link must contain at least one of '\
                "#{RELATIONSHIP_LINK_KEYS}.")
      end

      # @api private
      def self.validate_links!(links)
        ensure!(links.is_a?(Hash), 'A links object must be an object.')
        links.values.each { |link| validate_link!(link) }
      end

      # @api private
      def self.validate_link!(link)
        if link.is_a?(String)
        # Do nothing
        elsif link.is_a?(Hash)
        # TODO(beauby): Pending clarification request
        #   https://github.com/json-api/json-api/issues/1103
        else
          ensure!(false,
                  'The value of a link must be either a string or an object.')
        end
      end

      # @api private
      def self.validate_meta!(meta)
        ensure!(meta.is_a?(Hash), 'A meta object must be an object.')
      end

      # @api private
      def self.validate_jsonapi!(jsonapi)
        ensure!(jsonapi.is_a?(Hash), 'A JSONAPI object must be an object.')
        unexpected_keys = jsonapi.keys - JSONAPI_OBJECT_KEYS
        ensure!(unexpected_keys.empty?, 'Unexpected members for JSONAPI ' \
                                        "object: #{JSONAPI_OBJECT_KEYS}.")
        if jsonapi.key?('version')
          ensure!(jsonapi['version'].is_a?(String),
                  "Value of JSONAPI's version member must be a string.")
        end
        validate_meta!(jsonapi['meta']) if jsonapi.key?('meta')
      end

      # @api private
      def self.validate_included!(included)
        ensure!(included.is_a?(Array), 'Top level included member must be an ' \
                                       'array.')
        included.each { |res| validate_resource!(res) }
      end

      # @api private
      def self.validate_errors!(errors)
        ensure!(errors.is_a?(Array), 'Top level errors member must be an ' \
                                     'array.')
        errors.each { |error| validate_ensure!(error) }
      end

      # @api private
      def self.validate_ensure!(error)
        # NOTE(beauby): Do nothing for now, as errors are under-specified as of
        #   JSONAPI 1.0
      end

      # @api private
      def self.ensure!(condition, message)
        raise InvalidDocument, message unless condition
      end
    end
  end
end
