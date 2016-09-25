require 'jsonapi/serializable_link'
require 'jsonapi/serializable_relationship'

module JSONAPI
  class SerializableResource
    class << self
      attr_accessor :type_val, :type_block, :id_block, :attribute_blocks,
                    :relationship_blocks, :link_blocks, :meta_val, :meta_block

      def type(value = nil, &block)
        self.type_val = value
        self.type_block = block
      end

      def id(&block)
        self.id_block = block
      end

      def meta(value = nil, &block)
        self.meta_val = value
        self.meta_block = block
      end

      def attribute(name, &block)
        attribute_blocks[name] = block
      end

      def relationship(name, &block)
        relationship_blocks[name] = block
      end

      def link(name, &block)
        link_blocks[name] = block
      end
    end

    self.attribute_blocks = {}
    self.relationship_blocks = {}
    self.link_blocks = {}

    def self.inherited(klass)
      super
      klass.attribute_blocks = attribute_blocks.dup
      klass.relationship_blocks = relationship_blocks.dup
      klass.link_blocks = link_blocks.dup
    end

    def initialize(param_hash = {})
      param_hash.each { |k, v| instance_variable_set("@#{k}", v) }
      @_id = instance_eval(&self.class.id_block)
      @_type = self.class.type_val || instance_eval(&self.class.type_block)
      @_meta = if self.class.meta_val
                 self.class.meta_val
               elsif self.class.meta_block
                 instance_eval(&self.class.meta_block)
               end
      @_attributes = {}
      @_relationships = self.class.relationship_blocks
                            .each_with_object({}) do |(k, v), h|
        h[k] = JSONAPI::SerializableRelationship.new(param_hash, &v)
      end
      @_links = self.class.link_blocks
                    .each_with_object({}) do |(k, v), h|
        h[k] = JSONAPI::SerializableLink.as_jsonapi(param_hash, &v)
      end
    end

    def as_jsonapi(params = {})
      hash = {}
      hash[:id] = @_id
      hash[:type] = @_type
      attr = attributes(params[:fields] || @_attributes.keys)
      hash[:attributes] = attr if attr.any?
      rels = relationships(params[:field] || @_relationships.keys,
                           params[:include] || [])
      hash[:relationships] = rels if rels.any?
      hash[:links] = @_links if @_links.any?
      hash[:meta] = @_meta unless @_meta.nil?

      hash
    end

    def jsonapi_type
      @_type
    end

    def jsonapi_id
      @_id
    end

    def jsonapi_related(include)
      @_relationships
        .select { |k, _| include.include?(k) }
        .each_with_object({}) { |(k, v), h| h[k] = Array(v.data) }
    end

    private

    def attributes(fields)
      self.class.attribute_blocks
          .select { |k, _| !@_attributes.key?(k) && fields.include?(k) }
          .each { |k, v| @_attributes[k] = instance_eval(&v) }
      @_attributes.select { |k, _| fields.include?(k) }
    end

    def relationships(fields, include)
      @_relationships
        .select { |k, _| fields.include?(k) }
        .each_with_object({}) do |(k, v), h|
        h[k] = v.as_jsonapi(include.include?(k))
      end
    end
  end
end
