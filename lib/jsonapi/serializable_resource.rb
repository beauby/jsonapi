require 'jsonapi/serializable_link'
require 'jsonapi/serializable_relationship'

# TEMP
require 'active_support/core_ext/class/attribute'

module JSONAPI
  class SerializableResource
    class_attribute :type
    class_attribute :type_block
    class_attribute :id_block
    class_attribute :attribute_blocks
    class_attribute :relationship_blocks
    class_attribute :link_blocks
    class_attribute :meta
    class_attribute :meta_block

    def self.inherited(subclass)
      subclass.attribute_blocks = {}
      subclass.relationship_blocks = {}
      subclass.link_blocks = {}
    end
    
    def self.type(value = nil, &block)
      self.type = value
      self.type_block = block
    end

    def self.id(&block)
      self.id_block = block
    end

    def self.attribute(name, &block)
      self.attribute_blocks[name] = block
    end

    def self.relationship(name, &block)
      self.relationship_blocks[name] = block
    end
    
    def self.link(name, &block)
      self.link_blocks[name] = block
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

    def id
      @_id ||= instance_eval(&self.class.id_block)
    end

    def type
      @_type ||= (self.class.type || instance_eval(&self.class.type_block))
    end

    def attributes
      @_attributes ||=
        Hash[self.class.attribute_blocks.map { |k, v| [k, eval_attribute(v)] }]
    end

    def relationships
      @_relationships ||=
        Hash[self.class.relationship_blocks.map { |k, v| [k, eval_relationship(v)] }]
    end

    def links
      @_links ||= Hash[self.class.link_blocks.map { |k, v| [k, eval_link(v)] }]
    end

    def meta
      @_meta ||=
        if self.class.meta
          self.class.meta
        elsif self.class.meta_block
          instance_eval(&self.class.meta_block)
        end
    end

    private

    def eval_attribute(block)
      instance_eval(&block)
    end

    def eval_relationship(block)
      JSONAPI::SerializableRelationship.new(@_param_hash, &block)
    end

    def eval_link(block)
      JSONAPI::SerializableLink.new(@_param_hash, &block).to_hash
    end
  end
end
