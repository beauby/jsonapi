require 'jsonapi/parser/document'

module JSONAPI
  module Parser
    class Relationship
      # Validate the structure of a relationship update payload.
      #
      # @param [Hash] document The input JSONAPI document.
      # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
      def self.parse!(document)
        Document.ensure!(document.is_a?(Hash),
                         'A JSON object MUST be at the root of every JSONAPI ' \
                         'request and response containing data.')
        Document.ensure!(document.keys == ['data'].freeze,
                         'A relationship update payload must contain primary ' \
                         'data.')
        Document.parse_relationship_data!(document['data'])
      end
    end
  end
end
