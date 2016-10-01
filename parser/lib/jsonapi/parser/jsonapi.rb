module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#document-jsonapi-object
    class JsonApi
      attr_reader :version, :meta

      def initialize(jsonapi_hash, options = {})
        @hash = jsonapi_hash
        @version = jsonapi_hash['version'] if jsonapi_hash.key?('meta')
        @meta = jsonapi_hash['meta'] if jsonapi_hash.key?('meta')
      end

      def to_hash
        @hash
      end
    end
  end
end
