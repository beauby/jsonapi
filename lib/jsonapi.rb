require 'jsonapi/exceptions'
require 'jsonapi/version'

require 'jsonapi/attributes'
require 'jsonapi/document'
require 'jsonapi/error'
require 'jsonapi/jsonapi'
require 'jsonapi/link'
require 'jsonapi/links'
require 'jsonapi/relationship'
require 'jsonapi/relationships'
require 'jsonapi/resource'
require 'jsonapi/resource_identifier'

require 'jsonapi/parse'

if defined?(ActionController)
  require 'jsonapi/resource/to_params'
end

module JSONAPI
end
