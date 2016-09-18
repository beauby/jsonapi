module JSONAPI
  module_function

  # Parse a JSON API document.
  #
  # @param document [Hash, String] the JSON API document.
  # @param options [Hash] options
  # @option options [Boolean] :id_optional (false) whether the resource
  #   objects in the primary data must have an id
  # @return [JSON::API::Document]
  def parse(document, options = {})
    hash = document.is_a?(Hash) ? document : JSON.parse(document)

    Document.new(hash, options)
  end
end
