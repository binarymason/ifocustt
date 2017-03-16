module Focus
  class ChangeSlackDoNotDisturb < Action
    def perform
      res = Utils::WebClient.post(url)
      fail_action!(error: res) unless res.success?
    end

    private

    def url
      if context.enabled
        "#{base_url}&num_minutes=#{focus_minutes}"
      else
        base_url
      end
    end

    def base_url
      "#{config.slack_api_url}/#{action}?token=#{config.slack_token}"
    end

    def action
      context.enabled ? "dnd.setSnooze" : "dnd.endSnooze"
    end
  end
end
