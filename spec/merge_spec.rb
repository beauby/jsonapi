require 'jsonapi/include_directive'

describe JSONAPI::IncludeDirective, '.merge' do
  it 'works' do
    d1 = JSONAPI::IncludeDirective.new(
        {
            post: {
                comments: {
                    references: [:url]
                },
                author: [:address]
            }
        }
    )
    d2 = JSONAPI::IncludeDirective.new(
        {
            post: {
                comments: [:length],
                author: {},
                created_at: {}
            }
        }
    )
    expected = JSONAPI::IncludeDirective.new(
        {
            post: {
                comments: {
                    references: [:url],
                    length: {}
                },
                author: [:address],
                created_at: {}
            }
        }
    ).to_hash

    expect(d1.merge(d2).to_hash).to eq(expected)
    d1.merge!(d2)
    expect(d1.to_hash).to eq(expected)
  end
end
