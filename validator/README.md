# jsonapi-validator
Ruby gem for validating [JSON API](http://jsonapi.org) documents.

## Installation
```ruby
# In Gemfile
gem 'jsonapi-validator'
```
then
```
$ bundle
```
or manually via
```
$ gem install jsonapi-validator
```

## Usage

First, require the gem:
```ruby
require 'jsonapi/validator'
```
Then simply validate a document:
```ruby
# This will raise JSONAPI::Validator::InvalidDocument if an error is found.
JSONAPI.validate_document!(document_hash)
```
or a resource create/update payload:
```ruby
JSONAPI.validate_resource!(document_hash)
# Optionally, you can provide some resource-related constraints:
params = {
  permitted: {
    id: true,
    attributes: [:title, :date],
    relationships: [:comments, :author]
  },
  required: {
    id: true,
    attributes: [:title],
    relationships: [:comments, :author]
  },
  types: {
    primary: [:posts],
    relationships: {
      comments: {
        kind: :has_many,
        types: [:comments]
      },
      author: {
        kind: :has_one,
        types: [:users, :superusers]
      }
    }
  }
}
JSONAPI.parse_resource!(document_hash, params)
```
or a relationship update payload:
```ruby
JSONAPI.parse_relationship!(document_hash)
# Optionally, specify type information for the relationship:
JSONAPI.parse_relationship!(document_hash, kind: :has_many, types: [:comments])
```

## License

jsonapi-validator is released under the [MIT License](http://www.opensource.org/licenses/MIT).
