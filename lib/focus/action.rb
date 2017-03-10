require "httparty"
require "interactor"

module Focus
  class Action
    include Interactor

    private

    def focus_target
      context.target || "?"
    end

    def focus_minutes
      context.minutes.to_i
    end

    def focus_seconds
      context.minutes.to_f * 60
    end

    def debug_output(*args)
      Focus::STDOUT.debug_output args
    end
  end
end
