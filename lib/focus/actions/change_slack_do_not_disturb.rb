module Focus
  class ChangeSlackDoNotDisturb < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      SLACK_TOKEN ? HTTParty.post(url) : true
    end

    def url
      if context.enabled
        "#{base_url}&num_minutes=#{focus_minutes}"
      else
        base_url
      end
    end

    def base_url
      "#{SLACK_API_URL}/#{action}?token=#{SLACK_TOKEN}"
    end

    def action
      context.enabled ? "dnd.setSnooze" : "dnd.endSnooze"
    end
  end
end
