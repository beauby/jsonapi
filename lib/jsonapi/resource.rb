module JSONAPI
  # c.f. http://jsonapi.org/format/#document-resource-objects
  class Resource
    attr_reader :id, :type, :attributes, :relationships, :links, :meta

    def initialize(resource_hash, options = {})
      @hash = resource_hash
      validate!(options)
      @id = @hash['id']
      @type = @hash['type']
      attributes_hash = @hash['attributes'] || {}
      @attributes = Attributes.new(attributes_hash, options)
      relationships_hash = @hash['relationships'] || {}
      @relationships = Relationships.new(relationships_hash, options)
      links_hash = @hash['links'] || {}
      @links = Links.new(links_hash, options)
      @meta = @hash['meta'] if @hash.key?('meta')
    end

    def to_hash
      @hash
    end

    private

    def validate!(options)
      case
      when !options[:id_optional] && !@hash.key?('id')
        fail InvalidDocument, "a resource object MUST contain an 'id'"
      when !options[:id_optional] && !@hash['id'].is_a?(String)
        fail InvalidDocument, "the value of 'id' MUST be a string"
      when !@hash.key?('type')
        fail InvalidDocument, "a resource object MUST contain a 'type'"
      when !@hash['type'].is_a?(String)
        fail InvalidDocument, "the value of 'type' MUST be a string"
      end
    end
  end
end
