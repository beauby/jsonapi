class User
  include Virtus.model(finalize: false)

  attribute :id, Integer
  attribute :name, String
  attribute :email, String

  attribute :tweets, 'Tweet'
  attribute :friends, 'User'
  attribute :messages, Array['Message']
end

class Tweet
  include Virtus.model(finalize: false)

  attribute :id, Integer
  attribute :content, String
  attribute :created_at, Time, default: ->(_,_) { Time.now }
  attribute :updated_at, Time, default: ->(_,_) { Time.now }

  attribute :author, User
  attribute :parent, Tweet
  attribute :retweets, Array[Tweet]
end

class Message
  include Virtus.model(finalize: false)

  attribute :id, Integer
  attribute :content, String
  attribute :created_at, Time, default: ->(_,_) { Time.now }
  attribute :updated_at, Time, default: ->(_,_) { Time.now }

  attribute :sender, User
  attribute :receiver, User
end

Virtus.finalize

class UserResource < JSONAPI::Serializable::Resource
  type 'users'

  id do
    @user.id.to_s
  end

  attribute :name do
    @user.name
  end

  attribute :email do
    @user.email
  end

  relationship :tweets do
    data do
      @user.tweets.map do |t|
        TweetResource.new(tweet: t)
      end
    end
  end

  relationship :friends do
    data do
      @user.friends.map do |f|
        UserResource.new(user: f)
      end
    end
  end

  relationship :messages do
    data do
      @user.messages.map do |m|
        MessageResource.new(message: m)
      end
    end
  end
end

class TweetResource < JSONAPI::Serializable::Resource
  type 'tweets'

  id do
    @tweet.id.to_s
  end

  attribute :content do
    @tweet.content
  end

  attribute :date do
    @tweet.created_at
  end

  relationship :author do
    data do
      UserResource.new(user: @tweet.author)
    end
  end

  relationship :parent do
    data do
      if @tweet.parent
        TweetResource.new(tweet: @tweet.parent)
      end
    end
  end
end

class MessageResource < JSONAPI::Serializable::Resource
  type 'messages'

  id do
    @message.id.to_s
  end

  attribute :content do
    @message.content
  end

  attribute :date do
    @message.created_at
  end

  relationship :sender do
    data do
      UserResource.new(user: @message.sender)
    end
  end

  relationship :receiver do
    data do
      UserResource.new(user: @message.receiver)
    end
  end
end
