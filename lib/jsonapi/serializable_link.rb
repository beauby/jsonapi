module JSONAPI
  class SerializableLink
    def self.as_jsonapi(param_hash = {}, &block)
      new(param_hash, &block).as_jsonapi
    end

    def initialize(param_hash = {}, &block)
      param_hash.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      str_value = instance_eval(&block)
      @_href ||= str_value
    end

    def as_jsonapi
      @_hash ||=
        if @_meta.nil?
          @_href
        else
          { href: @_href, meta: @_meta }
        end
    end

    private

    def href(value = nil, &block)
      @_href = block.nil? ? value : instance_eval(&block)
    end

    def meta(value = nil, &block)
      @_meta = block.nil? ? value : instance_eval(&block)
    end
  end
end
