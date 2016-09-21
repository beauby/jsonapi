module JSONAPI
  # c.f. http://jsonapi.org/format/#document-resource-identifier-objects
  class ResourceIdentifier
    attr_reader :id, :type

    def initialize(resource_identifier_hash, _options = {})
      @hash = resource_identifier_hash

      validate!

      @id = @hash['id']
      @type = @hash['type']
    end

    def to_hash
      @hash
    end

    private

    def validate!
      case
      when !@hash.key?('id')
        fail InvalidDocument,
             "a resource identifier object MUST contain an 'id'"
      when !@hash['id'].is_a?(String)
        fail InvalidDocument, "the value of 'id' MUST be a string"
      when !@hash.key?('type')
        fail InvalidDocument,
             "a resource identifier object MUST contain a 'type'"
      when !@hash['type'].is_a?(String)
        fail InvalidDocument, "the value of 'type' MUST be a string"
      end
    end
  end
end
