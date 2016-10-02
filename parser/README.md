# jsonapi-parser
Ruby gem for parsing [JSON API](http://jsonapi.org) documents.

## Installation
```ruby
# In Gemfile
gem 'jsonapi-parser'
```
then
```
$ bundle
```
or manually via
```
$ gem install jsonapi-parser
```

## Usage

First, require the gem:
```ruby
require 'jsonapi/parser'
```
Then simply parse a document:
```ruby
# This will raise JSONAPI::Parser::InvalidDocument if an error is found.
JSONAPI.parse_response!(document_hash)
```
or a resource create/update payload:
```ruby
JSONAPI.parse_resource!(document_hash)
```
or a relationship update payload:
```ruby
JSONAPI.parse_relationship!(document_hash)
```

## License

jsonapi-parser is released under the [MIT License](http://www.opensource.org/licenses/MIT).
