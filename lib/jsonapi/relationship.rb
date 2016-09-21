module JSONAPI
  # c.f. http://jsonapi.org/format/#document-resource-object-relationships
  class Relationship
    attr_reader :data, :links, :meta

    def initialize(relationship_hash, options = {})
      @hash = relationship_hash
      links_hash = @hash['links'] || {}
      @links = Links.new(links_hash, options)
      @data = parse_linkage(@hash['data'], options) if @hash.key?('data')
      @meta = relationship_hash['meta'] if @hash.key?('meta')

      validate!
    end

    def to_hash
      @hash
    end

    def collection?
      @data.is_a?(Array)
    end

    private

    def validate!
      case
      when !@hash.key?('links') && !@hash.key?('data') && !@hash.key?('meta')
        fail InvalidDocument,
             "a relationship object MUST contain at least one of 'links'," \
             " 'data', or 'meta'"
      when @hash.key?('links') &&
           !@links.defined?(:self) &&
           !@links.defined?(:related)
        fail InvalidDocument,
             "the 'links' object of a relationship object MUST contain at" \
             " least one of 'self' or 'related'"
      end
    end

    def parse_linkage(linkage_hash, options)
      collection = linkage_hash.is_a?(Array)
      if collection
        linkage_hash.map { |h| ResourceIdentifier.new(h, options) }
      elsif !linkage_hash.nil?
        ResourceIdentifier.new(linkage_hash, options)
      else
        nil
      end
    end
  end
end
