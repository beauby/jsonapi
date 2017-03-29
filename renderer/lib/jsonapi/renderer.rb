require 'jsonapi/include_directive'

module JSONAPI
  class Renderer
    def initialize(resources, options = {})
      @resources = resources
      @errors = options[:errors] || false
      @meta = options[:meta] || nil
      @links = options[:links] || {}
      @fields = options[:fields] || {}
      # NOTE(beauby): Room for some nifty defaults on those.
      @jsonapi = options[:jsonapi_object] || nil
      @include = JSONAPI::IncludeDirective.new(options[:include] || {})
    end

    def as_json
      return @json unless @json.nil?

      traverse_resources
      process_resources
      build_json_document

      @json
    end

    def build_json_document
      @json = {}

      if @errors
        @json[:errors] = @resources.map(&:as_jsonapi)
      else
        @json[:data] = @resources.respond_to?(:each) ? @primary : @primary[0]
        @json[:included] = @included if @included.any?
      end
      @json[:links] = @links if @links.any?
      @json[:meta] = @meta unless @meta.nil?
      @json[:jsonapi] = @jsonapi unless @jsonapi.nil?
    end

    private

    def traverse_resources
      @traversed = Set.new # [type, id, prefix]
      @primary = []
      @included = []
      @include_rels = {} # [type, id => Set]
      @queue = []

      initialize_queue
      traverse_queue
    end

    def initialize_queue
      Array(@resources).each do |res|
        @traversed.add([res.jsonapi_type, res.jsonapi_id, ''])
        traverse_resource(res, @include.keys, true)
        enqueue_related_resources(res, '', @include)
      end
    end

    def traverse_queue
      until @queue.empty?
        res, prefix, include_dir = @queue.pop
        traverse_resource(res, include_dir.keys, false)
        enqueue_related_resources(res, prefix, include_dir)
      end
    end

    def traverse_resource(res, include_keys, primary)
      ri = [res.jsonapi_type, res.jsonapi_id]
      if @include_rels.include?(ri)
        @include_rels[ri].merge(include_keys)
      else
        @include_rels[ri] = Set.new(include_keys)
        (primary ? @primary : @included) << res
      end
    end

    def enqueue_related_resources(res, prefix, include_dir)
      res.jsonapi_related(include_dir.keys).each do |key, data|
        Array(data).each do |child_res|
          next if child_res.nil?
          child_prefix = "#{prefix}.#{key}"
          enqueue_resource(child_res, child_prefix, include_dir[key])
        end
      end
    end

    def enqueue_resource(res, prefix, include_dir)
      return unless @traversed.add?([res.jsonapi_type,
                                     res.jsonapi_id,
                                     prefix])
      @queue << [res, prefix, include_dir]
    end

    def process_resources
      [@primary, @included].each do |resources|
        resources.map! do |res|
          ri = [res.jsonapi_type, res.jsonapi_id]
          include_dir = @include_rels[ri]
          fields = @fields[res.jsonapi_type.to_sym]
          res.as_jsonapi(include: include_dir, fields: fields)
        end
      end
    end
  end

  module_function

  # Render a success JSON API document.
  #
  # @param [(#jsonapi_id, #jsonapi_type, #jsonapi_related, #as_jsonapi),
  #         Array<(#jsonapi_id, #jsonapi_type, #jsonapi_related, #as_jsonapi)>,
  #         nil] resources The primary resource(s) to be rendered.
  # @param [Hash] options All optional.
  #   @option [String, Hash{Symbol => Hash}] include Relationships to be
  #     included.
  #   @option [Hash{Symbol, Array<Symbol>}] fields List of requested fields
  #     for some or all of the resource types.
  #   @option [Hash] meta Non-standard top-level meta information to be
  #     included.
  #   @option [Hash] links Top-level links to be included.
  #   @option [Hash] jsonapi_object JSON API object.
  def render(resources, options = {})
    Renderer.new(resources, options).as_json
  end

  # Render an error JSON API document.
  #
  # @param [Array<#jsonapi_id>] errors Errors to be rendered.
  # @param [Hash] options All optional.
  #   @option [Hash] meta Non-standard top-level meta information to be
  #     included.
  #   @option [Hash] links Top-level links to be included.
  #   @option [Hash] jsonapi_object JSON API object.
  def render_errors(errors)
    Renderer.new(errors, errors: true).as_json
  end
end
