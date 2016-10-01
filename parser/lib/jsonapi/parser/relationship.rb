module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-resource-object-relationships
    class Relationship
      attr_reader :data, :links, :meta

      def initialize(relationship_hash, options = {})
        @hash = relationship_hash
        @options = options
        @links_defined = relationship_hash.key?('links')
        @data_defined = relationship_hash.key?('data')
        @meta_defined = relationship_hash.key?('meta')
        links_hash = relationship_hash['links'] || {}
        @links = Links.new(links_hash, @options)
        @data = parse_linkage(relationship_hash['data']) if
          @data_defined
        @meta = relationship_hash['meta'] if @meta_defined
      end

      def to_hash
        @hash
      end

      def collection?
        @data.is_a?(Array)
      end

      private

      def parse_linkage(linkage_hash)
        collection = linkage_hash.is_a?(Array)
        if collection
          linkage_hash.map { |h| ResourceIdentifier.new(h, @options) }
        elsif linkage_hash.nil?
          nil
        else
          ResourceIdentifier.new(linkage_hash, @options)
        end
      end
    end
  end
end
