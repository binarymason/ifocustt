module Focus
  class ChangeSlackDoNotDisturb < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      HTTParty.post(url)
    end

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
