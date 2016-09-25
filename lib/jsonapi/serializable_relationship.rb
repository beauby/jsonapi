require 'jsonapi/serializable_link'

module JSONAPI
  class SerializableRelationship
    def initialize(param_hash = {}, &block)
      @_param_hash = param_hash
      @_param_hash.each { |k, v| instance_variable_set("@#{k}", v) }
      @_links = {}
      instance_eval(&block)
    end

    def data(&block)
      if block.nil?
        @_data ||= @_data_block.call
      else
        @_data_block = block
      end
    end

    def as_jsonapi(included)
      hash = {}
      hash[:links] = @_links if @_links.any?
      hash[:meta] = @_meta unless @_meta.nil?
      hash[:data] = eval_linkage_data if included

      hash
    end

    private

    def eval_linkage_data
      @_linkage_data ||=
        if @_linkage_data_block
          @_linkage_data_block.call
        elsif data.respond_to?(:each)
          data.map { |res| { type: res.jsonapi_type, id: res.jsonapi_id } }
        elsif data.nil?
          nil
        else
          { type: data.jsonapi_type, id: data.jsonapi_id }
        end
    end

    def linkage_data(&block)
      @_linkage_data_block = block
    end

    def meta(value = nil)
      @_meta = value || yield
    end

    def link(name, &block)
      @_links[name] = JSONAPI::SerializableLink.as_jsonapi(@_param_hash, &block)
    end
  end
end
