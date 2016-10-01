require 'jsonapi/validator/document'
require 'jsonapi/validator/relationship'
require 'jsonapi/validator/resource'

module JSONAPI
  module_function

  # @see JSONAPI::Validator::Document.validate!
  def validate!(document)
    Validator::Document.validate!(document)
  end

  # @see JSONAPI::Validator::Resource.validate!
  def validate_resource!(document, params = {})
    Validator::Resource.validate!(document, params)
  end

  # @see JSONAPI::Validator::Relationship.validate!
  def validate_relationship!(document, params = {})
    Validator::Relationship.validate!(document, params)
  end
end
