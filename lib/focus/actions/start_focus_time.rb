require "yaml"
require "tty"

module Focus
  class StartFocusTime < Action
    DEFAULT_CONTEXT_KEYS = %i(minutes target quiet daemonize focus_start).freeze
    HOOKS = {
      focus:   "OnFocus",
      break:   "OnBreak",
      cleanup: "Cleanup"
    }.freeze

    attr_reader :action

    def perform
      context.actions = ConfigLoader.load("actions")
      parse_jira_ticket
      Focus::STDOUT.puts_line "Starting focus..."
      context.daemonize ? fork { _actions } : _actions
    end

    private

    def parse_jira_ticket
      context.jira_ticket = Utils::ParseJiraTicketFromGitBranch.call.jira_ticket
      Focus::STDOUT.puts_line "Working on JIRA ticket: '#{context.jira_ticket}'" if context.jira_ticket
    end

    def _actions
      execute_step(:focus) { handle_progress_bar }
      execute_step(:break) { handle_progress_bar }
    rescue SystemExit, Interrupt
      context.quiet = false
      Focus::STDOUT.title "Shutting down gracefully..."
    ensure
      execute_step(:cleanup)
      happy_message
    end

    def execute_step(step)
      @action = step.to_sym
      perform_actions HOOKS.fetch @action
      context.send("#{step}_start=", Time.now.to_i)
      yield if block_given?
    end

    def perform_actions(event)
      actions = actions_to_perform(event)
      return unless actions
      Focus::STDOUT.print_line "Starting #{event}...\r", quiet: context.quiet

      actions.each do |hsh|
        hsh.each do |action, keyword_arguments|
          klass = constantize("Focus::#{action}")
          args  = Formatter.downcase(keyword_arguments)

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

    def handle_progress_bar
      if context.daemonize
        every_second # sleep
      else
        every_second { progress_bar.advance }
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

    def progress_bar
      bar_type = @bar ? @bar.type : :not_defined
      return @bar if bar_type == action.to_s

      @bar = Formatter::ProgressBar.new(action, seconds: seconds_for_action)
    end

    def seconds_for_action
      case action.to_sym
      when :focus then focus_seconds
      when :break then break_seconds
      else
        raise "Unknown action: '#{action}'"
      end
    end

    def default_hsh
      slice_hash context.to_h, DEFAULT_CONTEXT_KEYS
    end

    def slice_hash(hsh, *args)
      keys = args.flatten
      hsh.select { |k, _v| keys.include? k }
    end

    def constantize(str)
      Object.const_get str
    end

    def happy_message
      return if context.quiet
      Focus::STDOUT.puts_line "\nProcess complete."
    end
  end
end
