module JSONAPI
  # c.f. http://jsonapi.org/format/#document-resource-object-relationships
  class Relationships
    include Enumerable

    def initialize(relationships_hash, options = {})
      @hash = relationships_hash
      fail InvalidDocument,
           "the value of 'relationships' MUST be an object" unless
        @hash.is_a?(Hash)

      @relationships = {}
      @hash.each do |rel_name, rel_hash|
        @relationships[rel_name.to_s] = Relationship.new(rel_hash, options)
        define_singleton_method(rel_name) do
          @relationships[rel_name.to_s]
        end
      end
    end

    def to_hash
      @hash
    end

    def each(&block)
      @relationships.each(&block)
    end

    def [](rel_name)
      @relationships[rel_name.to_s]
    end

    def defined?(rel_name)
      @relationships.key?(rel_name.to_s)
    end

    def keys
      @relationships.keys
    end
  end
end
