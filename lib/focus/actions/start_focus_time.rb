require "yaml"
require "tty"

module Focus
  class StartFocusTime < Action

    attr_reader :action

    def call
      context.actions = ConfigLoader.load
      focus
      take_break
      cleanup
    end

    private

    def focus
      @action = :focus
      perform_actions "OnFocus"
      handle_progress_bar
    end

    def take_break
      @action = :break
      perform_actions "OnBreak"
      handle_progress_bar
    end

    def cleanup
      if context.daemonize
        fork { perform_actions "OnCompletion" }
      else
        perform_actions "OnCompletion"
      end
    end

    def progress_bar
      bar_type = @bar ? @bar.format.split.first : :not_defined
      return @bar if bar_type == action.to_s

      @bar = build_progress_bar
    end

    def build_progress_bar
      TTY::ProgressBar.new "#{action} [:bar] :elapsed" do |config|
        config.total       = seconds_for_action
        config.interval    = 1
        config.width       = 40
      end
    end

    def seconds_for_action
      case action
      when :focus then focus_seconds
      when :break then break_seconds
      else
        raise "Unknown action: '#{action}'"
      end
    end

    def every_second
      end_time = Time.now + seconds_for_action

      while Time.now < end_time
        timestamp = Time.now
        yield
        interval = 1 - (Time.now - timestamp)
        sleep(interval) if interval.positive?
      end
    end

    def handle_progress_bar
      every_second { progress_bar.advance unless context.daemonize }
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
