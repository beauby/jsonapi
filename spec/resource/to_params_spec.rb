require 'action_controller'
require 'jsonapi'

describe JSONAPI::Resource, '.to_params' do
  before(:all) do
    @payload = ActionController::Parameters.new(
      'data' => {
        'type' => 'articles',
        'id' => '1',
        'attributes' => {
          'title' => 'JSON API paints my bikeshed!',
          'rating' => '5 stars'
        },
        'relationships' => {
          'author' => {
            'data' => { 'type' => 'people', 'id' => '9' }
          },
          'referree' => {
            'data' => nil
          },
          'publishing-journal' => {
            'data' => nil
          },
          'comments' => {
            'data' => [
              { 'type' => 'comments', 'id' => '5' },
              { 'type' => 'comments', 'id' => '12' }
            ]
          }
        }
      }
    )
  end

  it 'works' do
    document = JSONAPI.parse(@payload)

    options = {
      key_formatter: ->(x) { x.underscore }
    }
    actual = document.data
                     .to_params(options)
                     .permit(:id, :title, :author_id, :author_type,
                             :publishing_journal_id, comment_ids: [])
                     .to_h
    expected = {
      'id' => '1',
      'title' => 'JSON API paints my bikeshed!',
      'author_id' => '9',
      'author_type' => 'Person',
      'publishing_journal_id' => nil,
      'comment_ids' => ['5', '12']
    }

    expect(actual).to eq expected
  end

  it 'whitelists all attributes/relationships by default' do
    document = JSONAPI.parse(@payload)

    actual = document.data.to_params.to_unsafe_h
    expected = {
      'id' => '1',
      'title' => 'JSON API paints my bikeshed!',
      'rating' => '5 stars',
      'author_id' => '9',
      'author_type' => 'Person',
      'referree_id' => nil,
      'publishing-journal_id' => nil,
      'comment_ids' => ['5', '12']
    }

    expect(actual).to eq expected
  end
end
