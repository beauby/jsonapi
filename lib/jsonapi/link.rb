module JSONAPI
  # c.f. http://jsonapi.org/format/#document-links
  class Link
    # @return [String, Hash]
    attr_reader :value
    # @return [String]
    attr_reader :href
    # @return [Hash]
    attr_reader :meta

    def initialize(link_hash, options = {})
      @hash = link_hash

      validate!(link_hash)
      @value = link_hash
      unless link_hash.is_a?(Hash)
        link_hash = { 'href' => link_hash}
      end

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
