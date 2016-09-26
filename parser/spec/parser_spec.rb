require 'jsonapi/parser'

describe JSONAPI::Parser, '#parse' do
  before(:all) do
    @author_links_hash = {
      'self' => 'http://example.com/articles/1/relationships/author',
      'related' => 'http://example.com/articles/1/author'
    }
    @author_data_hash = { 'type' => 'people', 'id' => '9' }
    @comments_data_hash = [
      { 'type' => 'comments', 'id' => '5' },
      { 'type' => 'comments', 'id' => '12' }
    ]
    @article_relationships_hash = {
      'author' => {
        'links' => @author_links_hash,
        'data' => @author_data_hash
      },
      'journal' => {
        'data' => nil
      },
      'comments' => {
        'links' => {
          'self' => 'http://example.com/articles/1/relationships/comments',
          'related' => 'http://example.com/articles/1/comments'
        },
        'data' => @comments_data_hash
      }
    }
    @article_attributes_hash = { 'title' => 'JSON API paints my bikeshed!' }
    @article_links_hash = { 'self' => 'http://example.com/articles/1' }
    @data_hash = [{
      'type' => 'articles',
      'id' => '1',
      'attributes' => @article_attributes_hash,
      'links' => @article_links_hash,
      'relationships' => @article_relationships_hash
    }]
    @meta_hash = {
      'count' => '13'
    }

    @payload = {
      'data' => @data_hash,
      'meta' => @meta_hash
    }
  end

  it 'works' do
    document = JSONAPI.parse(@payload)

    expect(document.meta.keys).to eq ['count']
    expect(document.meta['count']).to eq '13'
    expect(document.data.first.links.keys).to eq ['self']
    expect(document.data.first.links.defined?(:self)).to be_truthy
    expect(document.data.first.links.self.value).to eq 'http://example.com/articles/1'
    expect(document.data.first.attributes.keys).to eq ['title']
    expect(document.data.first.attributes.defined?(:title)).to be_truthy
    expect(document.data.first.attributes.title).to eq 'JSON API paints my bikeshed!'
    expect(document.data.first.relationships.keys).to eq %w(author journal comments)
    expect(document.data.first.relationships.defined?(:author)).to be_truthy
    expect(document.data.first.relationships.author.collection?).to be_falsy
    expect(document.data.first.relationships.author.data.id).to eq '9'
    expect(document.data.first.relationships.author.data.type).to eq 'people'
    expect(document.data.first.relationships.author.links.keys).to eq ['self', 'related']
    expect(document.data.first.relationships.author.links.defined?(:self)).to be_truthy
    expect(document.data.first.relationships.author.links.self.value).to eq 'http://example.com/articles/1/relationships/author'
    expect(document.data.first.relationships.author.links.defined?(:related)).to be_truthy
    expect(document.data.first.relationships.author.links.related.value).to eq 'http://example.com/articles/1/author'
    expect(document.data.first.relationships.defined?(:comments)).to be_truthy
    expect(document.data.first.relationships.comments.collection?).to be_truthy
    expect(document.data.first.relationships.comments.data.size).to eq 2
    expect(document.data.first.relationships.comments.data[0].id).to eq '5'
    expect(document.data.first.relationships.comments.data[0].type).to eq 'comments'
    expect(document.data.first.relationships.comments.data[1].id).to eq '12'
    expect(document.data.first.relationships.comments.data[1].type).to eq 'comments'
    expect(document.data.first.relationships.comments.links.keys).to eq ['self', 'related']
    expect(document.data.first.relationships.comments.links.defined?(:self)).to be_truthy
    expect(document.data.first.relationships.comments.links.self.value).to eq 'http://example.com/articles/1/relationships/comments'
    expect(document.data.first.relationships.comments.links.defined?(:related)).to be_truthy
    expect(document.data.first.relationships.comments.links.related.value).to eq 'http://example.com/articles/1/comments'
    expect(document.data.first.relationships.defined?(:journal)).to be_truthy
    expect(document.data.first.relationships.journal.collection?).to be_falsy
    expect(document.data.first.relationships.journal.data).to eq nil

    expect(document.to_hash).to eq @payload
    expect(document.data.map(&:to_hash)).to eq @data_hash

    expect(document.data.first.attributes.to_hash).to eq @article_attributes_hash
    expect(document.data.first.links.to_hash).to eq @article_links_hash
    expect(document.data.first.relationships.to_hash).to eq @article_relationships_hash

    expect(document.data.first.relationships.author.links.to_hash).to eq @author_links_hash
    expect(document.data.first.relationships.author.data.to_hash).to eq @author_data_hash
    expect(document.data.first.relationships.comments.data.map(&:to_hash)).to eq @comments_data_hash
  end
end
