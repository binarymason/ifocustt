module Focus
  class StartRescueTime < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      token = Config.ifttt_maker_key
      if token
        url = "https://maker.ifttt.com/trigger/#{event}/with/key/#{token}"
        HTTParty.post url
      else
        true
      end
    end

    def event
      "rescue_time_focus_start"
    end
  end
end
