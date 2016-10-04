version = File.read(File.expand_path('../VERSION', __FILE__)).strip
parser_version =
  File.read(File.expand_path('../parser/VERSION', __FILE__)).strip
renderer_version =
  File.read(File.expand_path('../renderer/VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'Parse and render JSONAPI documents.'
  spec.description   = 'Efficiently parse and render JSONAPI documents.'
  spec.homepage      = 'https://github.com/beauby/jsonapi'
  spec.license       = 'MIT'

  spec.files         = ['README.md', 'lib/**/*']
  spec.require_path  = 'lib'

  spec.add_dependency 'jsonapi-parser', parser_version
  spec.add_dependency 'jsonapi-renderer', renderer_version

  spec.add_development_dependency 'rake', '>=0.9'
  spec.add_development_dependency 'rspec', '~>3.4'
end
