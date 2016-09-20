module JSONAPI
  # c.f. http://jsonapi.org/format/#document-top-level
  class Document
    attr_reader :data, :meta, :errors, :json_api, :links, :included

    def initialize(document_hash, options = {})
      @hash = document_hash
      @options = options
      @data_defined = document_hash.key?('data')
      @data = parse_data(document_hash['data']) if @data_defined
      @meta_defined = document_hash.key?('meta')
      @meta = parse_meta(document_hash['meta']) if @meta_defined
      @errors_defined = document_hash.key?('errors')
      @errors = parse_errors(document_hash['errors']) if @errors_defined
      @jsonapi_defined = document_hash.key?('jsonapi')
      @jsonapi = JsonApi.new(document_hash['jsonapi'], @options) if
        @jsonapi_defined
      @links_hash = document_hash['links'] || {}
      @links = Links.new(@links_hash, @options)
      @included_defined = document_hash.key?('included')
      @included = parse_included(document_hash['included']) if
        @included_defined

      link_relationships if @options[:link_relationships]

      validate!
    end

    def to_hash
      @hash
    end

    def collection?
      @data.is_a?(Array)
    end

    private

    def validate!
      case
      when !@data_defined && !@meta_defined && !@errors_defined
        fail InvalidDocument,
             "a document MUST contain at least one of 'data', 'meta', or" \
             " or 'errors' at top-level"
      when @data_defined && @errors_defined
        fail InvalidDocument,
             "'data' and 'errors' MUST NOT coexist in the same document"
      when !@data_defined && @included_defined
        fail InvalidDocument, "'included' MUST NOT be present unless 'data' is"
      when @options[:verify_duplicates] && duplicates?
        fail InvalidDocument,
             "resources MUST NOT appear both in 'data' and 'included'"
      when @options[:verify_linkage] && !full_linkage?
        fail InvalidDocument,
             "resources in 'included' MUST respect full-linkage"
      end
    end

    def index
      @index ||= Hash[(Array(data) + Array(included)).map { |r| [[r.type, r.id], r] }]
    end

    def link_relationships
      (Array(data) + Array(included)).each do |resource|
        resource.relationships.each do |_, rel|
          rel.link_resources(index)
        end
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
      queue.each { |resource| reachable << [resource.type, resource.id] }

      traverse = lambda do |rel|
        ri = [rel.type, rel.id]
        return unless index[ri]
        return unless reachable.add?(ri)
        queue << index[ri]
      end

      until queue.empty?
        resource = queue.pop
        resource.relationships.each do |_, rel|
          Array(rel.data).map(&traverse)
        end
      end

      index.keys.all? { |ri| reachable.include?(ri) }
    end

    def parse_data(data_hash)
      collection = data_hash.is_a?(Array)
      if collection
        data_hash.map { |h| Resource.new(h, @options.merge(id_optional: true)) }
      elsif data_hash.nil?
        nil
      else
        Resource.new(data_hash, @options.merge(id_optional: true))
      end
    end

    def parse_meta(meta_hash)
      fail InvalidDocument, "the value of 'meta' MUST be an object" unless
        meta_hash.is_a?(Hash)
      meta_hash
    end

    def parse_included(included_hash)
      fail InvalidDocument,
           "the value of 'included' MUST be an array of resource objects" unless
        included_hash.is_a?(Array)

      included_hash.map { |h| Resource.new(h, @options) }
    end

    def parse_errors(errors_hash)
      fail InvalidDocument,
           "the value of 'errors' MUST be an array of error objects" unless
        errors_hash.is_a?(Array)

      errors_hash.map { |h| Error.new(h, @options) }
    end
  end
end
