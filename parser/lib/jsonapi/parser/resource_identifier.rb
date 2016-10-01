module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-resource-identifier-objects
    class ResourceIdentifier
      attr_reader :id, :type

      def initialize(resource_identifier_hash, options = {})
        @hash = resource_identifier_hash
        @id = resource_identifier_hash['id']
        @type = resource_identifier_hash['type']
      end

      def to_hash
        @hash
      end
    end
  end
end
