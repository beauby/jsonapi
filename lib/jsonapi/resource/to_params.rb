require 'active_support/core_ext/string/inflections'

module JSONAPI
  class Resource
    # Transform the resource object into an instance of
    # +ActionController::Parameters+ ready to be fed into +ActiveRecord+
    # methods.
    #
    # @example
    #   payload = {
    #     'data' => {
    #       'type' => 'articles',
    #       'id' => '1',
    #       'attributes' => {
    #         'title' => 'JSON API paints my bikeshed!',
    #         'rating' => '5 stars'
    #       },
    #       'relationships' => {
    #         'author' => {
    #           'data' => { 'type' => 'people', 'id' => '9' }
    #         },
    #         'referree' => {
    #           'data' => nil
    #         },
    #         'publishing-journal' => {
    #           'data' => nil
    #         },
    #         'comments' => {
    #           'data' => [
    #             { 'type' => 'comments', 'id' => '5' },
    #             { 'type' => 'comments', 'id' => '12' }
    #           ]
    #         }
    #       }
    #     }
    #   }
    #   document = JSONAPI.parse(payload)
    #   options = {
    #     key_formatter: ->(x) { x.underscore }
    #   }
    #   document.data.to_activerecord_hash(options)
    #   # => {
    #          id: '1',
    #          title: 'JSON API paints my bikeshed!',
    #          author_id: '9',
    #          author_type: 'people',
    #          publishing_journal_id: nil,
    #          comment_ids: ['5', '12']
    #        }
    #
    # @param options [Hash]
    #   * :key_formatter (lambda)
    # @return [ActionController::Parameters]
    def to_params(options = {})
      options[:key_formatter] ||= ->(k) { k }

      hash = {}
      hash[:id] = id unless id.nil?
      hash.merge!(attributes_for_activerecord_hash(options[:key_formatter]))
      hash.merge!(relationships_for_activerecord_hash(options[:key_formatter]))

      ActionController::Parameters.new(hash)
    end

    private

    def attributes_for_activerecord_hash(key_formatter)
      attributes_hashes = attributes.keys.map do |key|
        attribute_for_activerecord_hash(key, key_formatter)
      end

      attributes_hashes.reduce({}, :merge)
    end

    def attribute_for_activerecord_hash(key, key_formatter)
      { key_formatter.call(key).to_sym => attributes[key] }
    end

    def relationships_for_activerecord_hash(key_formatter)
      relationship_hashes = relationships.keys.map do |key|
        relationship_for_activerecord_hash(key, key_formatter)
      end

      relationship_hashes.reduce({}, :merge)
    end

    def relationship_for_activerecord_hash(rel_name, key_formatter)
      rel = relationships[rel_name]
      key = key_formatter.call(rel_name)

      if rel.collection?
        to_many_relationship_for_activerecord_hash(key, rel)
      else
        to_one_relationship_for_activerecord_hash(key, rel)
      end
    end

    def to_many_relationship_for_activerecord_hash(key, rel)
      { "#{key.singularize}_ids".to_sym => rel.data.map(&:id) }
    end

    def to_one_relationship_for_activerecord_hash(key, rel)
      value = rel.data ? rel.data.id : nil
      hash = { "#{key}_id".to_sym => value }
      unless rel.data.nil?
        hash["#{key}_type".to_sym] = rel.data.type.singularize.capitalize
      end

      hash
    end
  end
end
