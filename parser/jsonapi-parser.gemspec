version = File.read(File.expand_path('../../JSONAPI_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi-parser'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'Parse and validate JSON API documents'
  spec.description   = 'Tools for handling JSON API documents'
  spec.homepage      = 'https://github.com/beauby/jsonapi'
  spec.license       = 'MIT'

  spec.files         = Dir['LICENSE', 'README.md', 'lib/**/*']
  spec.require_path  = 'lib'

  spec.add_dependency 'json', '~>1.8'
end
