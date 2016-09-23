require 'jsonapi/serializable_link'
require 'jsonapi/serializable_relationship'

# TEMP
require 'active_support/core_ext/class/attribute'

module JSONAPI
  class SerializableResource
    class_attribute :type
    class_attribute :type_block
    class_attribute :id_block
    class_attribute :attr_blocks
    class_attribute :rel_blocks
    class_attribute :link_blocks
    class_attribute :meta
    class_attribute :meta_block

    def self.inherited(subclass)
      subclass.attr_blocks = {}
      subclass.rel_blocks = {}
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
      self.attr_blocks[name] = block
    end

    def self.relationship(name, &block)
      self.rel_blocks[name] = block
    end
    
    def self.link(name, &block)
      self.link_blocks[name] = block
    end

    def self.meta(value = nil, &block)
      self.meta = value
      self.meta_block = block
    end

    def initialize(param_hash = {})
      param_hash.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
      @_id = instance_eval(&self.class.id_block)
      @_type = (self.class.type || instance_eval(&self.class.type_block))
      @_attributes =
        Hash[self.class.attr_blocks.map { |k, v| [k, instance_eval(&v)] }]
      @_relationships =
        Hash[self.class.rel_blocks.map { |k, v| [k, JSONAPI::SerializableRelationship.new(param_hash, &v)] }]
      @_links =
        Hash[self.class.link_blocks.map { |k, v| [k, JSONAPI::SerializableLink.new(param_hash, &v).to_hash] }]
      @_meta =
        if self.class.meta
          self.class.meta
        elsif self.class.meta_block
          instance_eval(&self.class.meta_block)
        end
    end

    [:id, :type, :attributes, :relationships, :links, :meta].each do |key|
      define_method(key) do
        instance_variable_get("@_#{key}")
      end
    end
  end
end
