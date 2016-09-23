require 'jsonapi/serializable_link'

module JSONAPI
  class SerializableRelationship
    def initialize(param_hash = {}, &block)
      @_param_hash = param_hash
      @_param_hash.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
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

    def linkage_data(&block)
      if block.nil?
        @_linkage_data ||=
          if @_linkage_data_block
            @_linkage_data_block.call
          elsif data.respond_to?(:each)
            data.map { |res| { type: res.type, id: res.id } }
          elsif data.nil?
            nil
          else
            { type: data.type, id: data.id }
          end
      else
        @_linkage_data_block = block
      end
    end

    def meta(value = nil, &block)
      if value.nil? && block.nil?
        @_meta
      else
        @_meta = (value || block.call)
      end
    end

    def links
      @_links
    end

    private

    def link(name, &block)
      @_links[name] = JSONAPI::SerializableLink.new(@_param_hash, &block).to_hash
    end
  end
end
