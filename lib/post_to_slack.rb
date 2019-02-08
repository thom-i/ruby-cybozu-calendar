require 'slack/incoming/webhooks'

class PostToSlack
  def self.notify message, channel, webhook
    slack = Slack::Incoming::Webhooks.new webhook, username: 'Calendar', channel: channel, icon_emoji: ":calendar:"
    slack.post message
  end
end