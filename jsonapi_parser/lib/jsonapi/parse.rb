require 'json'

require 'jsonapi/attributes'
require 'jsonapi/document'
require 'jsonapi/error'
require 'jsonapi/exceptions'
require 'jsonapi/jsonapi'
require 'jsonapi/link'
require 'jsonapi/links'
require 'jsonapi/relationship'
require 'jsonapi/relationships'
require 'jsonapi/resource'
require 'jsonapi/resource_identifier'
require 'jsonapi/parser/document'
require 'jsonapi/parser/exceptions'

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

    Parser::Document.new(hash, options)
  end
end
