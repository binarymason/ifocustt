require "yaml"
require "tty"

module Focus
  class StartFocusTime < Action
    def call
      context.actions = ConfigLoader.load
      focus
      take_break
      cleanup
    end

    private

    def focus
      perform_actions "OnFocus"
    end

    def take_break
      perform_actions "OnBreak"
    end

    def cleanup
      if context.daemonize
        fork { execute(quiet: true) }
      else
        execute
      end
    end

    def execute(quiet: false)
      every_second { advance_progress_bar unless quiet }
      perform_actions "OnCompletion"
    end

    def progress_bar
      @bar ||= TTY::ProgressBar.new "focusing [:bar] :elapsed" do |config|
        config.total    = focus_seconds
        config.interval = 1
        config.width    = 40
        config.clear    = true
      end
    end

    def every_second
      end_time = Time.now + focus_seconds

      while Time.now < end_time
        timestamp = Time.now
        yield
        interval = 1 - (Time.now - timestamp)
        sleep(interval) if interval.positive?
      end
    end

    def advance_progress_bar
      progress_bar.advance
    end

    def perform_actions(event)
      actions = context.actions[event]
      return unless actions

      actions.each do |action, keyword_arguments|
        klass = constantize(action)
        args  = downcase(keyword_arguments)

        evaluate_step(klass, args)
      end
    end

    def downcase(thing)
      return unless thing
      return thing.underscore if thing.respond_to? :underscore

      thing.each_with_object({}) do |(key, value), obj|
        obj[key.underscore] = value
      end
    end

    def constantize(str)
      Object.const_get "Focus::#{str}"
    end
  end
end
