version = File.read(File.expand_path('../JSONAPI_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'Parsing and rendering JSONAPI documents.'
  spec.description   = 'Parsing and rendering JSONAPI documents.'
  spec.homepage      = 'https://github.com/beauby/jsonapi'
  spec.license       = 'MIT'

  spec.files         = ['README.md']

  spec.add_dependency 'jsonapi-parser', version
  spec.add_dependency 'jsonapi-renderer', version

  spec.add_development_dependency 'rake', '>=0.9'
  spec.add_development_dependency 'rspec', '~>3.4'
end
