version = File.read(File.expand_path('../../JSONAPI_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi-renderer'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'Render JSONAPI documents.'
  spec.description   = 'Low-level renderer for JSONAPI documents.'
  spec.homepage      = 'https://github.com/beauby/jsonapi'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.require_path  = 'lib'
end
