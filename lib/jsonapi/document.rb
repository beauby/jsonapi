module JSONAPI
  # c.f. http://jsonapi.org/format/#document-top-level
  class Document
    attr_reader :data, :meta, :errors, :json_api, :links, :included

    def initialize(document_hash, options = {})
      @hash = document_hash
      @data = parse_data(@hash['data'], options) if @hash.key?('data')
      @meta = parse_meta(@hash['meta']) if @hash.key?('meta')
      @errors = parse_errors(@hash['errors'], options) if @hash.key?('errors')
      @jsonapi = JsonApi.new(@hash['jsonapi'], options) if @hash.key?('jsonapi')
      @links_hash = document_hash['links'] || {}
      @links = Links.new(@links_hash, options)
      @included = parse_included(@hash['included'], options) if
        @hash.key?('included')

      validate!(options)
    end

    def to_hash
      @hash
    end

    def collection?
      @data.is_a?(Array)
    end

    private

    def validate!(options)
      case
      when !@hash.key?('data') && !@hash.key?('meta') && !@hash.key?('errors')
        fail InvalidDocument,
             "a document MUST contain at least one of 'data', 'meta', or" \
             " or 'errors' at top-level"
      when @hash.key?('errors') && @hash.key?('data')
        fail InvalidDocument,
             "'data' and 'errors' MUST NOT coexist in the same document"
      when !@hash.key?('data') && @hash.key?('included')
        fail InvalidDocument, "'included' MUST NOT be present unless 'data' is"
      when options[:verify_duplicates] && duplicates?
        fail InvalidDocument,
             "resources MUST NOT appear both in 'data' and 'included'"
      when options[:verify_linkage] && !full_linkage?
        fail InvalidDocument,
             "resources in 'included' MUST respect full-linkage"
      end
    end

    def duplicates?
      resources = Set.new

      (Array(data) + Array(included)).each do |resource|
        return true unless resources.add?([resource.type, resource.id])
      end

      false
    end

    def full_linkage?
      return true unless @included

      reachable = Set.new
      # NOTE(lucas): Does Array() already dup?
      queue = Array(data).dup
      included_resources = Hash[included.map { |r| [[r.type, r.id], r] }]
      queue.each { |resource| reachable << [resource.type, resource.id] }

      traverse = lambda do |rel|
        ri = [rel.type, rel.id]
        return unless included_resources[ri]
        return unless reachable.add?(ri)
        queue << included_resources[ri]
      end

      until queue.empty?
        resource = queue.pop
        resource.relationships.each do |_, rel|
          Array(rel.data).map(&traverse)
        end
      end

      included_resources.keys.all? { |ri| reachable.include?(ri) }
    end

    def parse_data(data_hash, options)
      collection = data_hash.is_a?(Array)
      if collection
        data_hash.map { |h| Resource.new(h, options.merge(id_optional: true)) }
      elsif !data_hash.nil?
        Resource.new(data_hash, options.merge(id_optional: true))
      else
        nil
      end
    end

    def parse_meta(meta_hash)
      fail InvalidDocument, "the value of 'meta' MUST be an object" unless
        meta_hash.is_a?(Hash)
      meta_hash
    end

    def parse_included(included_hash, options)
      fail InvalidDocument,
           "the value of 'included' MUST be an array of resource objects" unless
        included_hash.is_a?(Array)

      included_hash.map { |h| Resource.new(h, options) }
    end

    def parse_errors(errors_hash, options)
      fail InvalidDocument,
           "the value of 'errors' MUST be an array of error objects" unless
        errors_hash.is_a?(Array)

      errors_hash.map { |h| Error.new(h, options) }
    end
  end
end
