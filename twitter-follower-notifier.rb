require 'slack/incoming/webhooks'
require 'twitter'

def post_follower_count(count)
  attachments = [{
    title: "フォロワー#{count}人ばい！",
    color: '#7CD197'
  }]

  slack = Slack::Incoming::Webhooks.new(ENV['WEBHOOK_URL'])
  slack.post(nil, attachments: attachments)
end

def call
  #
  # See more about twitter gem
  # https://github.com/sferik/twitter
  #
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
  #
  # See more about #user
  # http://www.rubydoc.info/gems/twitter/Twitter/REST/Users#user-instance_method
  #
  user = client.user(ENV['TWITTER_SCREEN_NAME'])

  post_follower_count(user.followers_count)
end

call
