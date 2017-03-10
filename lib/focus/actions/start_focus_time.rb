require "yaml"

module Focus
  class StartFocusTime < Action
    def call
      context.actions = YAML.load_file("./config/default.yml")
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
      fork do
        sleep focus_seconds
        perform_actions "OnCompletion"
      end
    end

    def perform_actions(event)
      actions = context.actions[event]
      return unless actions

      actions.each do |action, keyword_arguments|
        klass = constantize(action)
        args  = downcase(keyword_arguments)
        STDOUT.puts "#{klass}.call(#{args})" if $DEBUG
        klass.call(args)
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
