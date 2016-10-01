require 'jsonapi/validator/document'

module JSONAPI
  module Validator
    class Relationship
      # Validate the structure of a relationship update payload. Optionally
      #   validate the type of the related objects.
      #
      # @param [Hash] document The input JSONAPI document.
      # @param [Hash] params Validation parameters.
      #   @option [Array<Symbol>] types Permitted types for the relationship.
      # @raise [JSONAPI::Validator::InvalidDocument] if document is invalid.
      def self.validate_relationship!(document, params = {})
        Document.ensure!(document.is_a?(Hash),
                         'A JSON object MUST be at the root of every JSONAPI ' \
                         'request and response containing data.')
        Document.ensure!(document.key?('data'),
                         'A relationship update payload must contain primary ' \
                         'data.')
        Document.validate_relationship_data!(document['data'])
        validate_types!(document['data'], params[:types])
      end

      # @api private
      def self.validate_types!(rel, rel_types, key = nil)
        rel_name = key ? " #{key}" : ''
        if rel_types[:kind] == :has_many
          Document.ensure!(rel['data'].is_a?(Array),
                           "Expected relationship#{rel_name} to be has_many.")
          rel['data'].each do |ri|
            Document.ensure!(rel_types.types.include?(ri['type'].to_sym),
                             "Type mismatch for relationship#{rel_name}: " \
                             "#{ri['type']} should be one of #{rel_types}")
          end
        else
          return if rel['data'].nil?
          Document.ensure!(rel['data'].is_a?(Hash),
                           "Expected relationship#{rel_name} to be has_one.")
          ri = rel['data']
          Document.ensure!(rel_types.types.include?(ri['type'].to_sym),
                           "Type mismatch for relationship#{rel_name}: " \
                           "#{ri['type']} should be one of #{rel_types}")
        end
      end
    end
  end
end
