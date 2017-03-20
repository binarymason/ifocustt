module Focus
  module Formatter
    class ProgressBar
      attr_reader :bar

      def initialize(action, seconds:)
        @bar = build_progress_bar(action, seconds)
      end

      def advance
        @bar.advance
      end

      def build_progress_bar(action, seconds)
        TTY::ProgressBar.new "#{action} [:bar] :elapsed" do |config|
          config.total       = seconds
          config.interval    = 1
          config.width       = 40
        end
      end

      def type
        bar.format.to_s.split.first
      end
    end
  end
end
