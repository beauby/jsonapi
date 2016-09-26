module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-resource-objects
    class Resource
      attr_reader :id, :type, :attributes, :relationships, :links, :meta

      def initialize(resource_hash, options = {})
        @hash = resource_hash
        @options = options.dup
        @id_optional = @options.delete(:id_optional)
        validate!(resource_hash)
        @id = resource_hash['id']
        @type = resource_hash['type']
        @attributes_hash = resource_hash['attributes'] || {}
        @attributes = Attributes.new(@attributes_hash, @options)
        @relationships_hash = resource_hash['relationships'] || {}
        @relationships = Relationships.new(@relationships_hash, @options)
        @links_hash = resource_hash['links'] || {}
        @links = Links.new(@links_hash, @options)
        @meta = resource_hash['meta'] if resource_hash.key?('meta')
      end

      def to_hash
        @hash
      end

      private

      def validate!(resource_hash)
        case
        when !@id_optional && !resource_hash.key?('id')
          # We might want to take care of
          # > Exception: The id member is not required when the resource object
          # > originates at the client and represents a new resource to be created
          # > on the server.
          # in the future.
          fail InvalidDocument, "a resource object MUST contain an 'id'"
        when !@id_optional && !resource_hash['id'].is_a?(String)
          fail InvalidDocument, "the value of 'id' MUST be a string"
        when !resource_hash.key?('type')
          fail InvalidDocument, "a resource object MUST contain a 'type'"
        when !resource_hash['type'].is_a?(String)
          fail InvalidDocument, "the value of 'type' MUST be a string"
        end
      end
    end
  end
end
