require 'jsonapi/parser'

describe JSONAPI::Parser, '.parse_response!' do
  it 'works' do
    author_links_hash = {
      'self' => 'http://example.com/articles/1/relationships/author',
      'related' => 'http://example.com/articles/1/author'
    }
    author_data_hash = { 'type' => 'people', 'id' => '9' }
    comments_data_hash = [
      { 'type' => 'comments', 'id' => '5' },
      { 'type' => 'comments', 'id' => '12' }
    ]
    article_relationships_hash = {
      'author' => {
        'links' => author_links_hash,
        'data' => author_data_hash
      },
      'journal' => {
        'data' => nil
      },
      'comments' => {
        'links' => {
          'self' => 'http://example.com/articles/1/relationships/comments',
          'related' => 'http://example.com/articles/1/comments'
        },
        'data' => comments_data_hash
      }
    }
    article_attributes_hash = { 'title' => 'JSON API paints my bikeshed!' }
    article_links_hash = { 'self' => 'http://example.com/articles/1' }
    data_hash = [
      {
        'type' => 'articles',
        'id' => '1',
        'attributes' => article_attributes_hash,
        'links' => article_links_hash,
        'relationships' => article_relationships_hash
      }
    ]
    meta_hash = {
      'count' => '13'
    }

    payload = {
      'data' => data_hash,
      'meta' => meta_hash
    }

    expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  end
end
