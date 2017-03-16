require "yaml"
require "tty"

module Focus
  class StartFocusTime < Action
    DEFAULT_CONTEXT_KEYS = %i(minutes target quiet daemonize focus_start).freeze

    attr_reader :action

    def perform
      context.actions = ConfigLoader.load("actions")
      parse_jira_ticket
      Focus::STDOUT.puts_line "Starting focus..."
      context.daemonize ? fork { _actions } : _actions
    end

    private

    def _actions
      focus
      take_break
    rescue SystemExit, Interrupt
      context.quiet = false
      Focus::STDOUT.title "Shutting down gracefully..."
    ensure
      cleanup
      happy_message
    end

    def parse_jira_ticket
      context.jira_ticket = Utils::ParseJiraTicketFromGitBranch.call.jira_ticket
      Focus::STDOUT.puts_line "Working on JIRA ticket: '#{context.jira_ticket}'" if context.jira_ticket
    end

    def focus
      @action = :focus
      perform_actions "OnFocus"
      context.focus_start = Time.now.to_i
      handle_progress_bar
    end

    def take_break
      @action = :break
      perform_actions "OnBreak"
      handle_progress_bar
    end

    def cleanup
      perform_actions "Cleanup"
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
        yield if block_given?
        interval = 1 - (Time.now - timestamp)
        sleep(interval) if interval.positive?
      end
    end

    def handle_progress_bar
      if context.daemonize
        every_second # sleep
      else
        every_second { progress_bar.advance }
      end
    end

    def perform_actions(event)
      actions = actions_to_perform(event)
      return unless actions
      Focus::STDOUT.print_line "Starting #{event}...\r", quiet: context.quiet

      actions.each do |hsh|
        hsh.each do |action, keyword_arguments|
          klass = constantize(action)
          args  = downcase(keyword_arguments)

          _evaluate_step klass, with_default_context(args)
        end
      end
    end

    def actions_to_perform(event)
      actions = context.actions.find { |x| x.keys.include? event }
      actions[event] if actions
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
      return if context.quiet
      Focus::STDOUT.puts_line "\nProcess complete."
    end

    def constantize(str)
      Object.const_get "Focus::#{str}"
    end
  end
end
