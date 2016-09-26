module JSONAPI
  module Parser
    # c.f. http://jsonapi.org/format/#error-objects
    class Error
      attr_reader :id, :links, :status, :code, :title, :detail, :source, :meta

      def initialize(error_hash, options = {})
        fail InvalidDocument,
             "the value of 'errors' MUST be an array of error objects" unless
          error_hash.is_a?(Hash)

        @hash = error_hash
        @id = error_hash['id'] if error_hash.key?('id')
        links_hash = error_hash['links'] || {}
        @links = Links.new(links_hash, options)
        @status = error_hash['status'] if error_hash.key?('status')
        @code = error_hash['code'] if error_hash.key?('code')
        @title = error_hash['title'] if error_hash.key?('title')
        @detail = error_hash['detail'] if error_hash.key?('detail')
        @source = error_hash['source'] if error_hash.key?('source')
        @meta = error_hash['meta'] if error_hash.key?('meta')
      end

      def to_hash
        @hash
      end
    end
  end
end
