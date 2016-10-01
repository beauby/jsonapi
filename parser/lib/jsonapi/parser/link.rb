module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-links
    class Link
      attr_reader :value, :href, :meta

      def initialize(link_hash, options = {})
        @hash = link_hash

        @value = link_hash
        return unless link_hash.is_a?(Hash)

        @href = link_hash['href']
        @meta = link_hash['meta']
      end

      def to_hash
        @hash
      end
    end
  end
end
