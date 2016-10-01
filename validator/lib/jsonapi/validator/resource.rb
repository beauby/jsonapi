require 'jsonapi/validator/document'
require 'jsonapi/validator/relationship'

module JSONAPI
  module Validator
    class Resource
      # Validate the structure of a resource create/update payload. Optionally
      #   validate whitelisted/required id/attributes/relationships, as well as
      #   primary type and relationship types.
      #
      # @param [Hash] document The input JSONAPI document.
      # @param [Hash] params Validation parameters.
      #   @option [Hash] permitted Permitted attributes/relationships/primary
      #     id. Optional. If not supplied, all legitimate fields are permitted.
      #   @option [Hash] required Required attributes/relationships/primary id.
      #     Optional. The fields must be explicitly permitted, or permitted
      #     should not be provided.
      #   @option [Hash] types Permitted primary/relationships types. Optional.
      #     The relationships must be explicitly permitted. Not all
      #     relationships' types have to be specified.
      # @raise [JSONAPI::Validator::InvalidDocument] if document is invalid.
      #
      # @example
      #   params = {
      #     permitted: {
      #       id: true, # Simply ommit it to forbid it.
      #       attributes: [:title, :date],
      #       relationships: [:comments, :author]
      #     },
      #     required: {
      #       id: true,
      #       attributes: [:title],
      #       relationships: [:comments, :author]
      #     },
      #     types: {
      #       primary: [:posts],
      #       relationships: {
      #         comments: {
      #           kind: :has_many,
      #           types: [:comments]
      #         },
      #         author: {
      #           kind: :has_one,
      #           types: [:users, :superusers]
      #         }
      #       }
      #     }
      #   }
      def self.validate!(document, params = {})
        Document.ensure!(document.is_a?(Hash),
                         'A JSON object MUST be at the root of every JSONAPI ' \
                         'request and response containing data.')
        Document.ensure!(document.key?('data') || !document['data'].is_a?(Hash),
                         'The request MUST include a single resource object ' \
                         'as primary data.')
        Document.validate_primary_resource!(document['data'])

        validate_permitted!(document['data'], params[:permitted])
        validate_required!(document['data'], params[:required])
        validate_types!(document['data'], params[:types])
      end

      # @api private
      def self.validate_permitted!(data, permitted)
        return if permitted.nil?
        Document.ensure!(permitted[:id] || !data.key?('id'),
                         'Unpermitted id.')
        # TODO(beauby): Handle meta (and possibly links) once the spec has
        #   been clarified.
        permitted_attrs = permitted[:attributes] || []
        if data.key?('attributes')
          data['attributes'].keys.each do |attr|
            Document.ensure!(permitted_attrs.include?(attr.to_sym),
                             "Unpermitted attribute #{attr}")
          end
        end
        permitted_rels = permitted[:relationships] || []
        if data.key?('relationships')
          data['relationships'].keys.each do |rel|
            Document.ensure!(permitted_rels.include?(rel.to_sym))
          end
        end
      end

      # @api private
      def self.validate_required!(data, required)
        return if required.nil?
        Document.ensure!(data.key?('id') || !required[:id],
                         'Missing required id.')
        # TODO(beauby): Same as for permitted.

        Document.ensure!(data.key?('attributes') || !required[:attributes],
                         'Missing required attributes.')
        required[:attributes].each do |attr|
          Document.ensure!(data['attributes'][attr.to_s],
                           "Missing required attribute #{attr}.")
        end
        Document.ensure!(data.key?('relationships') ||
                         !required[:relationships],
                         'Missing required relationships.')
        required[:relationships].each do |rel|
          Document.ensure!(data['relationships'][rel.to_s],
                           "Missing required relationship #{rel}.")
        end
      end

      # @api private
      def self.validate_types!(data, types)
        return if types.nil?
        Document.ensure!(!types[:primary] ||
                         types[:primary].include?(data['type']),
                         "Type mismatch for resource: #{data['type']} " \
                         "should be one of #{types[:primary]}")
        return unless data.key?('relationships') && types.key?(:relationships)
        types[:relationships].each do |key, rel_types|
          rel = data['relationships'][key.to_s]
          next unless rel
          Relationship.validate_types(rel, rel_types, key)
        end
      end
    end
  end
end
