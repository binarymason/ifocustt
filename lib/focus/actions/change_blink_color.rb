module Focus
  class ChangeBlinkColor < Action
    def call
      context.fail! unless perform
    end

    private

    def perform
      system "curl '#{BLINK_SERVER}/fadeToRGB?rgb=%#{context.color}' &>/dev/null"
    end
  end
end
