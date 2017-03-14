module Focus
  class ChangeSlackDoNotDisturb < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      Config.slack_token ? HTTParty.post(url) : true
    end

    def url
      if context.enabled
        "#{base_url}&num_minutes=#{focus_minutes}"
      else
        base_url
      end
    end

    def base_url
      "#{Config.slack_api_url}/#{action}?token=#{Config.slack_token}"
    end

    def action
      context.enabled ? "dnd.setSnooze" : "dnd.endSnooze"
    end
  end
end
