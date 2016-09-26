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

Then, parse a JSON API document:
```ruby
document = JSONAPI.parse(json_hash)
```

## Examples

```ruby
  document = JSONAPI.parse(json_hash)
  # Should the document be invalid, the parse method would fail with a
  #   JSONAPI::Parser::InvalidDocument error.

  document.data.links.defined?(:self)
  # => true
  document.data.links.self.value
  # => 'http://example.com/articles/1'
  document.data.attributes.keys
  # => ['title']
  document.data.attributes.defined?(:title)
  # => true
  document.data.attributes.title
  # => 'JSON API paints my bikeshed!'
  document.data.relationships.keys
  # => ['author', 'comments']
  document.data.relationships.defined?(:author)
  # => true
  document.data.relationships.author.collection?
  # => false
  document.data.relationships.author.data.id
  # => 9
  document.data.relationships.author.data.type
  # => 'people'
  document.data.relationships.author.links.defined?(:self)
  # => true
  document.data.relationships.author.links.self.value
  # => 'http://example.com/articles/1/relationships/author'
  document.data.relationships.defined?(:comments)
  # => true
  document.data.relationships.comments.collection?
  # => true
  document.data.relationships.comments.data.size
  # => 2
  document.data.relationships.comments.data[0].id
  # => 5
  document.data.relationships.comments.data[0].type
  # => 'comments'
  document.data.relationships.comments.links.defined?(:self)
  # => true
  document.data.relationships.comments.links.self.value
  # => 'http://example.com/articles/1/relationships/comments'

  # for the following document_hash
  document_hash = {
    'data' =>
      {
        'type' => 'articles',
        'id' => '1',
        'attributes' => {
          'title' => 'JSON API paints my bikeshed!'
        },
        'links' => {
          'self' => 'http://example.com/articles/1'
        },
        'relationships' => {
          'author' => {
            'links' => {
              'self' => 'http://example.com/articles/1/relationships/author',
              'related' => 'http://example.com/articles/1/author'
            },
            'data' => { 'type' => 'people', 'id' => '9' }
          },
          'comments' => {
            'links' => {
              'self' => 'http://example.com/articles/1/relationships/comments',
              'related' => 'http://example.com/articles/1/comments'
            },
            'data' => [
              { 'type' => 'comments', 'id' => '5' },
              { 'type' => 'comments', 'id' => '12' }
            ]
          }
        }
      }
    }
```

## License

jsonapi-parser is released under the [MIT License](http://www.opensource.org/licenses/MIT).
