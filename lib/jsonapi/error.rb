module JSONAPI
  # c.f. http://jsonapi.org/format/#error-objects
  class Error
    attr_reader :id, :links, :status, :code, :title, :detail, :source, :meta

    def initialize(error_hash, options = {})
      @hash = error_hash
      fail InvalidDocument,
           "the value of 'errors' MUST be an array of error objects" unless
        @hash.is_a?(Hash)

      @id = @hash['id']
      links_hash = @hash['links'] || {}
      @links = Links.new(links_hash, options)
      @status = @hash['status']
      @code = @hash['code']
      @title = @hash['title']
      @detail = @hash['detail']
      @source = @hash['source']
      @meta = @hash['meta']
    end

    def to_hash
      @hash
    end
  end
end
