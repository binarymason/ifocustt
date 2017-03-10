module Focus
  class StartRescueTime < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      if IFTTT_MAKER_KEY
        url = "https://maker.ifttt.com/trigger/#{event}/with/key/#{IFTTT_MAKER_KEY}"
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
