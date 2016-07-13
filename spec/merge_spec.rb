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
    )

    merged_directive = d1.merge(d2)
    expected = expected.to_hash
    actual = merged_directive.to_hash

    expect(actual).to eq expected
  end
end
