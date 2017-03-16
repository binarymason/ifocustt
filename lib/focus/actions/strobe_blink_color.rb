module Focus
  class StrobeBlinkColor < Action
    def perform
      res = Utils::WebClient.get(url)
      fail_action!(error: res) unless res.success?
    end

    private

    def url
      "#{config.blink_server}/pattern?rgb=%#{context.color}&time=1.5&repeats=0"
    end
  end
end
