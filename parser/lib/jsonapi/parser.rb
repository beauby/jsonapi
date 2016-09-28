require 'jsonapi/parser/attributes'
require 'jsonapi/parser/document'
require 'jsonapi/parser/error'
require 'jsonapi/parser/exceptions'
require 'jsonapi/parser/jsonapi'
require 'jsonapi/parser/link'
require 'jsonapi/parser/links'
require 'jsonapi/parser/relationship'
require 'jsonapi/parser/relationships'
require 'jsonapi/parser/resource'
require 'jsonapi/parser/resource_identifier'

module JSONAPI
  module_function

  # Parse a JSON API document.
  #
  # @param document [Hash] the JSON API document.
  # @param options [Hash] options
  #   @option options [Boolean] :id_optional (false) Whether the resource
  #     objects in the primary data must have an id.
  # @return [JSONAPI::Parser::Document]
  def parse(document, options = {})
    raise Parser::InvalidDocument, 'document must be a hash' unless document.is_a?(Hash)
    Parser::Document.new(document, options)
  end
end
