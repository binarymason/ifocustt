require "httparty"
require "interactor"

module Focus
  class FailedActionError < StandardError; end

  class Action
    include Interactor

    private

    def focus_target
      context.focus_target || context.target || "?"
    end

    def focus_minutes
      context.focus_minutes || context.minutes.to_i
    end

    def focus_seconds
      context.minutes.to_f * 60
    end

    def break_seconds
      focus_seconds * 0.2
    end

    def evaluate_step(klass, args)
      action = klass.to_s.gsub(/^.*::/, "")
      step = "Running #{action}..."

      Focus::STDOUT.step(step, quiet: context.quiet) do
        result = klass.call(args)
        raise FailedActionError, error_message(result) unless result.success?
      end
    end

    def error_message(obj)
      "#{obj.action}: #{obj.error}"
    end

    def debug_output(*args)
      Focus::STDOUT.debug_output args
    end

    def fail_action!(opts = {})
      context.fail!(opts.merge(action: self.class.to_s.split("::").last))
    end
  end
end
