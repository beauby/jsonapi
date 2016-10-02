require 'jsonapi/parser/document'
require 'jsonapi/parser/relationship'
require 'jsonapi/parser/resource'

module JSONAPI
  module_function

  # @see JSONAPI::Parser::Document.validate!
  def parse_response!(document)
    Parser::Document.parse!(document)
  end

  # @see JSONAPI::Parser::Resource.validate!
  def parse_resource!(document)
    Parser::Resource.parse!(document)
  end

  # @see JSONAPI::Parser::Relationship.validate!
  def parse_relationship!(document)
    Parser::Relationship.parse!(document)
  end
end
