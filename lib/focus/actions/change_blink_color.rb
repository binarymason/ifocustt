module Focus
  class ChangeBlinkColor < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      url = "#{BLINK_SERVER}/fadeToRGB?rgb=%#{context.color}"
      res = HTTParty.get(url)
      res.code == 200
    end
  end
end
