module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-links
    class Link
      attr_reader :value, :href, :meta

      def initialize(link_hash, options = {})
        @hash = link_hash

        validate!(link_hash)
        @value = link_hash
        return unless link_hash.is_a?(Hash)

        @href = link_hash['href']
        @meta = link_hash['meta']
      end

      def to_hash
        @hash
      end

      private

      def validate!(link_hash)
        case
        when !link_hash.is_a?(String) && !link_hash.is_a?(Hash)
          fail InvalidDocument,
               "a 'link' object MUST be either a string or an object"
        when link_hash.is_a?(Hash) && (!link_hash.key?('href') ||
                                       !link_hash['href'].is_a?(String))
          fail InvalidDocument,
               "a 'link' object MUST be either a string or an object containing" \
               " an 'href' string"
        when link_hash.is_a?(Hash) && (!link_hash.key?('meta') ||
                                       !link_hash['meta'].is_a?(Hash))
          fail InvalidDocument,
               "a 'link' object MUST be either a string or an object containing" \
               " an 'meta' object"
        end
      end
    end
  end
end
