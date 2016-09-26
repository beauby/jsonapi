version = File.expand_path('../JSONAPI_VERSION', __FILE__).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'JSON API toolbox'
  spec.description   = 'Tools for parsing/rendering JSON API documents'
  spec.homepage      = 'https://github.com/beauby/jsonapi'
  spec.license       = 'MIT'

  spec.files         = ['README.md']

  spec.add_dependency 'jsonapi-parser', version
end
