require "yaml"
require "tty"

module Focus
  class StartFocusTime < Action
    DEFAULT_CONTEXT_KEYS = %i(minutes target quiet daemonize).freeze

    attr_reader :action

    def call
      context.actions = ConfigLoader.load("actions")
      focus
      take_break
      cleanup
      happy_message
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
      actions = context.actions.shift[event]
      return unless actions
      Focus::STDOUT.print_line "Starting #{event}...\r"

      actions.each do |hsh|
        hsh.each do |action, keyword_arguments|
          klass = constantize(action)
          args  = downcase(keyword_arguments)

          evaluate_step klass, with_default_context(args)
        end
      end
    end

    def with_default_context(args)
      hsh = args.to_h
      hsh.merge default_hsh
    end

    def default_hsh
      slice_hash context.to_h, DEFAULT_CONTEXT_KEYS
    end

    def slice_hash(hsh, *args)
      keys = args.flatten
      hsh.select { |k, _v| keys.include? k }
    end

    def downcase(thing)
      return unless thing
      return thing.underscore if thing.respond_to? :underscore

      thing.each_with_object({}) do |(key, value), obj|
        obj[key.underscore] = value
      end
    end

    def happy_message
      Focus::STDOUT.puts_line nil
      Focus::STDOUT.puts_line "Complete!"
    end

    def constantize(str)
      Object.const_get "Focus::#{str}"
    end
  end
end
