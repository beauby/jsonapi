lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi'
  spec.version       = JSONAPI::VERSION
  spec.authors       = ['Lucas Hosseini']
  spec.email         = ['lucas.hosseini@gmail.com']
  spec.summary       = 'Parse and validate JSON API documents'
  spec.description   = 'Tools for handling JSON API documents'
  spec.homepage      = 'https://github.com/beauby/jsonapi'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'json', '~>1.8'

  spec.add_development_dependency 'rake', '>=0.9'
  spec.add_development_dependency 'rspec', '~>3.4'
  spec.add_development_dependency 'activesupport', '>=3.0'
  spec.add_development_dependency 'actionpack'
end
