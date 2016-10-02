require 'jsonapi/parser/document'

module JSONAPI
  module Parser
    class Resource
      # Validate the structure of a resource create/update payload.
      #
      # @param [Hash] document The input JSONAPI document.
      # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
      def self.parse!(document)
        Document.ensure!(document.is_a?(Hash),
                         'A JSON object MUST be at the root of every JSONAPI ' \
                         'request and response containing data.')
        Document.ensure!(document.keys == ['data'].freeze &&
                         document['data'].is_a?(Hash),
                         'The request MUST include a single resource object ' \
                         'as primary data.')
        Document.parse_primary_resource!(document['data'])
      end
    end
  end
end
