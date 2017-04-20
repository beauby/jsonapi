require 'spec_helper'

RSpec.describe 'simple rendering' do
  let(:user1) { User.new(id: 1, name: 'dhh', email: 'dhh@rails.com') }
  let(:user2) { User.new(id: 2, name: 'wycats', email: 'wycats@ember.com') }

  let(:tweet) { Tweet.new(content: "Tweet", retweets: retweet) }
  let(:retweet) { Tweet.new(author: user2, parent: tweet) }

  let(:resource_klass) { Class.new(UserResource) }
  let(:resource) { resource_klass.new(user: user1) }
  let(:options) { {} }

  let(:rendered) do
    JSONAPI.render(resource, options)
  end

  let!(:now) { Time.now }

  before do
    allow(Time).to receive(:now) { now }
  end

  it 'renders valid jsonapi' do
    expect(rendered).to eq({
      data: {
        id: '1',
        type: 'users',
        attributes: {
          name: 'dhh',
          email: 'dhh@rails.com'
        },
        relationships: {
          tweets: {},
          friends: {},
          messages: {}
        }
      }
    })
  end

  context 'when limiting fields' do
    before do
      options.merge!(fields: { users: [:email] })
    end

    it 'only renders the specified fields' do
      expect(rendered).to eq({
        data: {
          id: '1',
          type: 'users',
          attributes: {
            email: 'dhh@rails.com'
          }
        }
      })
    end
  end

  context 'when specifying meta' do
    before do
      options.merge!(meta: { took: 12 })
    end

    it 'adds meta node to the payload' do
      expect(rendered[:meta]).to eq({
        took: 12
      })
    end
  end

  context 'when the resource has top-level links' do
    before do
      resource_klass.class_eval do
        link(:self) do
          "http://test.com/users/#{@user.id}"
        end
      end
    end

    it 'renders the link' do
      expect(rendered[:data][:links]).to eq({
        self: 'http://test.com/users/1'
      })
    end
  end

  context 'when the resource has relationship-level links' do
    before do
      resource_klass.class_eval do
        relationship :messages do
          link(:related) do
            "http://test.com/messages?filter[user_id]=#{@user.id}"
          end
        end
      end
    end

    it 'renders the link' do
      expect(rendered[:data][:relationships][:messages]).to eq({
        links: {
          related: 'http://test.com/messages?filter[user_id]=1'
        }
      })
    end
  end

  context 'when sideloading' do
    let!(:message) do
      Message.new id: '1',
        content: 'Hello',
        sender: user1,
        receiver: user2
    end

    before do
      user1.messages << message
      options.merge!(include: 'messages.receiver')
    end

    it 'renders sideloads in included payload' do
      expect(rendered).to eq({
        data: {
          id: '1',
          type: 'users',
          attributes: {
            name: 'dhh',
            email: 'dhh@rails.com'
          },
          relationships: {
            tweets: {},
            friends: {},
            messages: {
              data: [
                {
                  id: '1',
                  type: 'messages'
                }
              ]
            }
          }
        },
        included: [
          {
            id: '1',
            type: 'messages',
            attributes: {
              content: 'Hello',
              date: now
            },
            relationships: {
              sender: {},
              receiver: {
                data: {
                  id: '2',
                  type: 'users'
                }
              }
            }
          },
          {
            id: '2',
            type: 'users',
            attributes: {
              name: 'wycats',
              email: 'wycats@ember.com'
            },
            relationships: {
              tweets: {},
              friends: {},
              messages: {}
            }
          }
        ]
      })
    end
  end
end
