module JSONAPI
  class SerializableLink
    def initialize(param_hash = {}, &block)
      param_hash.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      str_value = instance_eval(&block)
      @_href ||= str_value
    end

    def to_hash
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
