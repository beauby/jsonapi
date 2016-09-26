module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-resource-identifier-objects
    class ResourceIdentifier
      attr_reader :id, :type

      def initialize(resource_identifier_hash, options = {})
        @hash = resource_identifier_hash

        validate!(resource_identifier_hash)

        @id = resource_identifier_hash['id']
        @type = resource_identifier_hash['type']
      end

      def to_hash
        @hash
      end

      private

      def validate!(resource_identifier_hash)
        case
        when !resource_identifier_hash.key?('id')
          fail InvalidDocument,
               "a resource identifier object MUST contain an 'id'"
        when !resource_identifier_hash['id'].is_a?(String)
          fail InvalidDocument, "the value of 'id' MUST be a string"
        when !resource_identifier_hash.key?('type')
          fail InvalidDocument,
               "a resource identifier object MUST contain a 'type'"
        when !resource_identifier_hash['type'].is_a?(String)
          fail InvalidDocument, "the value of 'type' MUST be a string"
        end
      end
    end
  end
end
