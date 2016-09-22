require 'jsonapi/serializable_link'

# TEMP
require 'active_support/core_ext/class/attribute'

module JSONAPI
  class SerializableErrorSource
    def initialize(params = {})
      params.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    def as_json
      hash = {}
      hash[:pointer] = pointer unless pointer.nil?
      hash[:parameter] = parameter unless parameter.nil?

      hash
    end

    private

    def pointer(value = nil, &block)
      if value.nil? && block.nil?
        @_pointer
      else
        @_pointer = (value || instance_eval(&block))
      end
    end

    def parameter(value = nil, &block)
      if value.nil? && block.nil?
        @_parameter
      else
        @_parameter = (value || instance_eval(&block))
      end
    end
  end

  class SerializableError
    class_attribute :id
    class_attribute :id_block
    class_attribute :link_blocks
    class_attribute :status
    class_attribute :status_block
    class_attribute :code
    class_attribute :code_block
    class_attribute :title
    class_attribute :title_block
    class_attribute :detail
    class_attribute :detail_block
    class_attribute :source
    class_attribute :source_block
    class_attribute :meta
    class_attribute :meta_block

    self.link_blocks = {}

    def self.id(value = nil, &block)
      self.id = value
      self.id_block = block
    end

    def self.link(name, &block)
      self.link_blocks[name] = block
    end

    def self.status(value = nil, &block)
      self.status = value
      self.status_block = block
    end

    def self.code(value = nil, &block)
      self.code = value
      self.code_block = block
    end

    def self.title(value = nil, &block)
      self.title = value
      self.title_block = block
    end

    def self.detail(value = nil, &block)
      self.detail = value
      self.detail_block = block
    end

    def self.source(value = nil, &block)
      self.source = value
      self.source_block = block
    end

    def self.meta(value = nil, &block)
      self.meta = value
      self.meta_block = block
    end

    def initialize(params = {})
      @_param_hash = params
      params.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    # TODO: those are optional fields
    def id
      @_id ||=
        if self.class.id_block
          instance_eval(self.class.id_block)
        elsif 
          self.class.id
        end
    end

    def links
      @_links ||= self.class.link_blocks
                .each_with_object({}) do |(name, block), hash|
        hash[name] = JSONAPI::SerializableLink.new(@_param_hash, block).to_hash
      end
    end

    def status
      @_status ||=
        if self.class.status_block
          instance_eval(self.class.status_block)
        else
          self.class.status
        end
    end

    def code
      @_code ||=
        if self.class.code_block
          instance_eval(self.class.code_block)
        else
          self.class.code
        end
    end

    def title
      @_title ||=
        if self.class.title_block
          instance_eval(self.class.title_block)
        else
          self.class.title
        end
    end

    def detail
      @_detail ||=
        if self.class.detail_block
          instance_eval(self.class.detail_block)
        else
          self.class.detail
        end
    end

    def source
      @_source ||=
        if self.class.source_block
          instance_eval(self.class.source_block)
        else
          self.class.source
        end
    end

    def meta
      @_meta =
        if self.class.meta_block
          instance_eval(self.class.meta_block)
        else
          self.class.meta
        end
    end
  end
end
