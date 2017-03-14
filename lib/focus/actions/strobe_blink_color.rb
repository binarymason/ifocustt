module Focus
  class StrobeBlinkColor < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      url = "#{Config.blink_server}/pattern?rgb=%#{context.color}&time=1.5&repeats=0"
      res = HTTParty.get(url)
      res.code == 200
    end
  end
end
