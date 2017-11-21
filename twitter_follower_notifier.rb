require './twitter_client.rb'
require 'slack/incoming/webhooks'

# Notify followers_count of twitter users
# Specified by the screen_names
class FollowerNotifier
  COLORS = %w[#7CD197 #3366FF #33CCFF #33FFCC #6633FF #003DF5 #B88A00 #66FF33 #CC33FF #002EB8 #F5B800 #FF33CC #FF3366 #FF6633 #FFCC33].freeze

  def self.call
    # Comma separated screen_name of Twitter
    screen_names = ENV['TWITTER_SCREEN_NAMES'].split(',')

    attachments = []
    screen_names.each_with_index do |name, index|
      attachments << compose_attachement(name: name, index: index)
    end

    slack = Slack::Incoming::Webhooks.new(ENV['WEBHOOK_URL'])
    slack.post(nil, attachments: attachments)
  end

  class << self
    private

    def compose_attachement(name: 'Default Name', index: 0)
      targets = ENV['TWITTER_FOLLOWER_TARGETS'].split(',')
      url, count = profile(name)

      attachment = {
        author_name: name,
        author_link: "https://twitter.com/#{name}",
        author_icon: url,
        fields: [
          { title: 'Followers', value: count, short: true }
        ],
        color: COLORS[index]
      }
      if targets && targets[index]
        attachment[:fields] << {
          title: 'Target',
          value: targets[index], short: true
        }
        attachment[:fields] << {
          title: (ENV['TWITTER_TARGET_DIFF_MESSAGE'] || 'Diff'),
          value: (targets[index].to_i - count), short: true
        }
      end

      attachment
    end

    def profile(name)
      #
      # See more about #user
      # http://www.rubydoc.info/gems/twitter/Twitter/REST/Users#user-instance_method
      #
      user = Twitter.client.user(name)
      [user.profile_image_url, user.followers_count]
    end
  end
end

FollowerNotifier.call
