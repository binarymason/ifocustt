module Focus
  class ChangeBlinkColor < Action
    def perform
      StartBlinkServer.call
      url = "#{config.blink_server}/fadeToRGB?rgb=%#{context.color}"
      res = Utils::WebClient.get(url)
      fail_action!(error: "Could not change blink(1) color.") unless res.success?
    end
  end
end
