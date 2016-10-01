module JSONAPI
  module Parser
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
        if @options[:verify_duplicates] && duplicates?
          raise JSONAPI::Validator::InvalidDocument,
               "resources MUST NOT appear both in 'data' and 'included'"
        elsif @options[:verify_linkage] && !full_linkage?
          raise JSONAPI::Validator::InvalidDocument,
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
        queue = Array(data)
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

      def parse_data(data_hash)
        collection = data_hash.is_a?(Array)
        if collection
          data_hash.map { |h| Resource.new(h, @options) }
        elsif data_hash.nil?
          nil
        else
          Resource.new(data_hash, @options)
        end
      end

      def parse_meta(meta_hash)
        meta_hash
      end

      def parse_included(included_hash)
        included_hash.map { |h| Resource.new(h, @options) }
      end

      def parse_errors(errors_hash)
        errors_hash.map { |h| Error.new(h, @options) }
      end
    end
  end
end
