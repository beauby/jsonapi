module JSONAPI
  # c.f. http://jsonapi.org/format/#document-links
  class Link
    attr_reader :value, :href, :meta

    def initialize(link_hash, _options = {})
      @hash = link_hash

      validate!

      if @hash.is_a?(Hash)
        @href = @hash['href']
        @meta = @hash['meta']
      else
        @value = @hash
      end
    end

    def to_hash
      @hash
    end

    private

    def validate!
      case
      when !@hash.is_a?(String) && !@hash.is_a?(Hash)
        fail InvalidDocument,
             "a 'link' object MUST be either a string or an object"
      when @hash.is_a?(Hash) && (!@hash.key?('href') ||
                                 !@hash['href'].is_a?(String))
        fail InvalidDocument,
             "a 'link' object MUST be either a string or an object containing" \
             " an 'href' string"
      when @hash.is_a?(Hash) && (!@hash.key?('meta') ||
                                 !@hash['meta'].is_a?(Hash))
        fail InvalidDocument,
             "a 'link' object MUST be either a string or an object containing" \
             " an 'meta' object"
      end
    end
  end
end
