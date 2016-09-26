require 'jsonapi/parser'

describe JSONAPI::Parser, '#parse' do
  it 'succeeds when no included property is provided' do
    payload = {
      'data' => [
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
        }]
    }

    JSONAPI.parse(payload, verify_linkage: true)
  end

  it 'succeeds when full linkage is respected' do
    payload = {
      'data' => [
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
        }],
      'included' => [
        {
          'type' => 'comments',
          'id' => '5'
        }, {
          'type' => 'comments',
          'id' => '12'
        }, {
          'type' => 'comments',
          'id' => '13'
        }, {
          'type' => 'people',
          'id' => '9',
          'relationships' => {
            'comments' => {
              'data' => [
                {
                  'type' => 'comments',
                  'id' => '13'
                }
              ]
            }
          }
        }
      ]
    }

    JSONAPI.parse(payload, verify_linkage: true)
  end

  it 'fails when full linkage is not respected' do
    payload = {
      'data' => [
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
        }],
      'included' => [
        {
          'type' => 'comments',
          'id' => '5'
        }, {
          'type' => 'comments',
          'id' => '12'
        }, {
          'type' => 'comments',
          'id' => '13'
        }
      ]
    }

    expect { JSONAPI.parse(payload, verify_linkage: true) }
      .to raise_error(JSONAPI::Parser::InvalidDocument)
  end
end
