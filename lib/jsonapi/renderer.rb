module JSONAPI
  class Renderer
    def initialize(resources, options = {})
      @resources = resources
      @errors = options[:errors] || false
      @meta = options[:meta] || nil
      @links = options[:links] || {}
      @fields = options[:fields] || {}
      # NOTE(beauby): Room for some nifty defaults on those.
      @jsonapi = nil
      @include = JSONAPI::IncludeDirective.new(options[:include] || {})
    end

    def as_json
      return @json unless @json.nil?

      process_resources
      @json = {}

      if @errors
        @json[:errors] = @resources.map(&:error_hash)
      else
        @json[:data] = @resources.respond_to?(:each) ? @primary : @primary[0]
        @json[:included] = @included if @included.any?
      end
      @json[:links] = @links if @links.any?
      @json[:meta] = @meta unless @meta.nil?
      @json[:jsonapi] = @jsonapi unless @jsonapi.nil?

      @json
    end

    private

    def process_resources
      @primary = []
      @included = []
      @hashes = {}
      @processed = Set.new  # NOTE(beauby): Set of [type, id, prefix].
      @queue = []

      Array(@resources).each do |res|
        process_resource(res, "", @include, true)
        @processed.add([res.type, res.id, ""])
      end
      until @queue.empty? do
        res, prefix, include_dir = @queue.pop
        process_resource(res, prefix, include_dir, false)
      end
    end

    def resource_identifier(res)
      [res.type, res.id]
    end

    def process_resource(res, prefix, include_dir, is_primary)
      hash = (@hashes[resource_identifier(res)] ||= {})
      if hash.empty?
        hash[:id] = res.id
        hash[:type] = res.type
        filtered_attributes = filter_fields(res.type, res.attributes)
        hash[:attributes] = filtered_attributes if filtered_attributes.any?
        hash[:links] = res.links if res.links.any?
        hash[:meta] = res.meta unless res.meta.nil?
        if is_primary
          @primary << hash
        else
          @included << hash
        end
      end
      process_relationships(hash, res, prefix, include_dir)
    end

    def process_relationships(hash, res, prefix, include_dir)
      whitelist = @fields[res.type.to_sym]
      res.relationships.each do |key, rel|
        if include_dir.key?(key) # NOTE(beauby): || always_include_linkage
          Array(rel.data).each do |child_res|
            child_prefix = prefix + key.to_s
            next unless @processed.add?([child_res.type, child_res.id, child_prefix])
            @queue << [child_res, child_prefix, include_dir[key]]
          end
        end

        if whitelist.nil? || whitelist.include?(key)
          hash[:relationships] ||= {}
          rel_hash = (hash[:relationships][key] ||= {})
          if rel_hash.empty?
            rel_hash[:links] = rel.links if rel.links.any?
            rel_hash[:meta] = rel.meta unless rel.meta.nil?
          end
          if include_dir.key?(key) && !rel_hash.key?(:data)
            data =
              if rel.linkage_data.nil?
                Array(rel.data).map do |rel_res|
                  type, id = resource_identifier(rel_res)
                  { type: type, id: id }
                end
              else
                Array(rel.linkage_data)
              end
            rel_hash[:data] = rel.data.respond_to?(:each) ? data : data[0]
          end
        end
      end
    end

    def field_whitelist(type)
      @fields[type.to_sym]
    end

    def filter_fields(type, hash)
      whitelist = @fields[type.to_sym]
      return hash if whitelist.nil?
      hash.select { |k, _| whitelist.include?(k) }
    end

    def error_hash(error)
      hash = {}
      hash[:id] = error.id unless error.id.nil?
      hash[:links] = error.links unless error.links.nil?
      hash[:status] = error.status unless error.status.nil?
      hash[:code] = error.code unless error.code.nil?
      hash[:title] = error.title unless error.title.nil?
      hash[:detail] = error.detail unless error.detail.nil?
      hash[:source] = error.source unless error.source.nil?
      hash[:meta] = error.meta unless error.meta.nil?

      hash
    end
  end

  module_function

  def render(resources, options = {})
    Renderer.new(resources, options).as_json
  end
end
