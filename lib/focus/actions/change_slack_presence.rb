module Focus
  class ChangeSlackPresence < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      token = config.slack_token
      if token
        url = "#{config.slack_api_url}/users.setPresence?token=#{token}&presence=#{presence}"
        res = HTTParty.post url
        res.code == 200
      else
        true
      end
    end

    def presence
      context.presence
    end
  end
end
