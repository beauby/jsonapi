module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-resource-objects
    class Resource
      attr_reader :id, :type, :attributes, :relationships, :links, :meta

      def initialize(resource_hash, options = {})
        @hash = resource_hash
        @options = options.dup
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
    end
  end
end
