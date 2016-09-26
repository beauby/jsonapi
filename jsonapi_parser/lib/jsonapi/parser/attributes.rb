module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-resource-object-attributes
    class Attributes
      include Enumerable

      def initialize(attributes_hash, options = {})
        fail InvalidDocument,
             "the value of 'attributes' MUST be an object" unless
          attributes_hash.is_a?(Hash)

        @hash = attributes_hash
        @attributes = {}
        attributes_hash.each do |attr_name, attr_val|
          @attributes[attr_name.to_s] = attr_val
          define_singleton_method(attr_name) do
            @attributes[attr_name.to_s]
          end
        end
      end

      def to_hash
        @hash
      end

      def each(&block)
        @attributes.each(&block)
      end

      def [](attr_name)
        @attributes[attr_name.to_s]
      end

      def defined?(attr_name)
        @attributes.key?(attr_name.to_s)
      end

      def keys
        @attributes.keys
      end
    end
  end
end
