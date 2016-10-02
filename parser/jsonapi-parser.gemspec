version = File.read(File.expand_path('../../JSONAPI_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi-parser'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'Parse JSONAPI documents.'
  spec.description   = 'Parse JSONAPI response documents, resource ' \
                       'creation/update payloads, and relationship ' \
                       'update payloads.'
  spec.homepage      = 'https://github.com/beauby/jsonapi'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.require_path  = 'lib'
end
