require 'json'

module JSONAPI
  module_function

  # Parse a JSON API document.
  #
  # @param document [Hash, String] the JSON API document.
  # @param options [Hash] options
  # @option options [Boolean] :id_optional (false) whether the resource
  #   objects in the primary data must have an id
  # @return [JSONAPI::Document]
  def parse(document, options = {})
    hash =
      if document.is_a?(Hash)
        document
      elsif document.is_a?(String)
        JSON.parse(document)
      elsif defined?(ActionController) && document.is_a?(ActionController::Parameters)
        document.to_unsafe_h
      end

    Document.new(hash, options)
  end
end
