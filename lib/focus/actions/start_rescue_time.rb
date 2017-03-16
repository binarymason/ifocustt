module Focus
  class StartRescueTime < Action
    def perform
      res = Utils::WebClient.post url
      fail_action!(error: res) unless res.success?
    end

    private

    def token
      config.ifttt_maker_key
    end

    def url
      "https://maker.ifttt.com/trigger/#{event}/with/key/#{token}"
    end

    def event
      "rescue_time_focus_start"
    end
  end
end
