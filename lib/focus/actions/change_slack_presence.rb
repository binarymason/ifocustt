module Focus
  class ChangeSlackPresence < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      if SLACK_TOKEN
        url = "#{SLACK_API_URL}/users.setPresence?token=#{SLACK_TOKEN}&presence=#{presence}"
        system"curl -X POST '#{url}' &>/dev/null"
      else
        true
      end
    end

    def presence
      context.presence
    end
  end
end
