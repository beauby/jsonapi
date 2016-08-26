module JSONAPI
  # c.f. http://jsonapi.org/format/#document-links
  class Links
    # @param [Hash] links_hash
    # @param [Hash] options
    def initialize(links_hash, options = {})
      fail InvalidDocument, "the value of 'links' MUST be an object" unless
        links_hash.is_a?(Hash)

      @hash = links_hash
      @links = {}
      links_hash.each do |link_name, link_val|
        @links[link_name.to_s] = Link.new(link_val, options)
        define_singleton_method(link_name) do
          @links[link_name.to_s]
        end
      end
    end

    # @return [Hash]
    def to_hash
      @hash
    end

    # @param [String] link_name
    # @return [Boolean]
    def defined?(link_name)
      @links.key?(link_name.to_s)
    end

    # @param [String] link_name
    # @return [JSONAPI::Link]
    def [](link_name)
      @links[link_name.to_s]
    end

    # @return [<String>]
    def keys
      @links.keys
    end
  end
end
