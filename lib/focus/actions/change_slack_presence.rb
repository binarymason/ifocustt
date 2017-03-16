module Focus
  class ChangeSlackPresence < Action
    def perform
      res = Utils::WebClient.post url
      fail_action!(error: res) unless res.success?
    end

    private

    def token
      config.slack_token
    end

    def url
      "#{config.slack_api_url}/users.setPresence?token=#{token}&presence=#{presence}"
    end

    def presence
      context.presence
    end
  end
end
