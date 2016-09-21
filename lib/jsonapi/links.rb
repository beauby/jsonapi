module JSONAPI
  # c.f. http://jsonapi.org/format/#document-links
  class Links
    def initialize(links_hash, options = {})
      @hash = links_hash
      fail InvalidDocument, "the value of 'links' MUST be an object" unless
        @hash.is_a?(Hash)

      @links = {}
      links_hash.each do |link_name, link_val|
        @links[link_name.to_s] = Link.new(link_val, options)
        define_singleton_method(link_name) do
          @links[link_name.to_s]
        end
      end
    end

    def to_hash
      @hash
    end

    def defined?(link_name)
      @links.key?(link_name.to_s)
    end

    def [](link_name)
      @links[link_name.to_s]
    end

    def keys
      @links.keys
    end
  end
end
