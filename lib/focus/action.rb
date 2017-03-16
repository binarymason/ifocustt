require "httparty"
require "interactor"

module Focus
  class FailedActionError < StandardError; end

  # A small wrapper to an Action's context.
  # If an attribute is defined in the context, it will be returned.
  # Otherwise, a lookup within Focus::Config will take place.
  class ContextualConfiguration
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def method_missing(m, *args, &block) # rubocop:disable MethodMissing
      context.send(m) || Config.send(m, *args, &block)
    end
  end

  class Action
    include Interactor

    def perform; end

    def error_message
      "#{self.class.to_s.split('::').last} failed"
    end

    # This method is used internally and should not be used within actions.
    def call
      perform
    end

    def config
      ContextualConfiguration.new(context)
    end

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

    def seconds_focused
      Time.now.to_i - context.focus_start
    end

    def break_seconds
      focus_seconds * 0.2
    end

    def fail_action!(opts = {})
      raise ArgumentError, "An `:error` key must be provided to fail an action" unless (opts.keys & [:error, "error"]).any?
      context.fail!(opts.merge(action: self.class.to_s.split("::").last))
    end

    def _evaluate_step(klass, args)
      action = klass.to_s.gsub(/^.*::/, "")
      step = "Running #{action}..."

      Focus::STDOUT.step(step, quiet: context.quiet) do
        result = klass.call(args)
        raise FailedActionError, _failed_action_error(result) unless result.success?
      end
    end

    def _failed_action_error(obj)
      "#{obj.action}: #{obj.error}"
    end

    def debug_output(*args)
      Focus::STDOUT.debug_output args
    end
  end
end
