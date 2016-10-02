require 'jsonapi/parser'

describe JSONAPI::Parser, '.parse_response!' do
  it 'works' do
    payload = {
      'data' => [
        {
          'type' => 'articles',
          'id' => '1',
          'attributes' => { 'title' => 'JSON API paints my bikeshed!' },
          'links' => { 'self' => 'http://example.com/articles/1' },
          'relationships' => {
            'author' => {
              'links' => {
                'self' => 'http://example.com/articles/1/relationships/author',
                'related' => 'http://example.com/articles/1/author'
              },
              'data' => { 'type' => 'people', 'id' => '9' }
            },
            'journal' => {
              'data' => nil
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
      ],
      'meta' => { 'count' => '13' }
    }

    expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  end
end
