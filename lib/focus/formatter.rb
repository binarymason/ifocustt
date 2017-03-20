require "paint"

module Focus
  module Formatter
    module_function

    def step(step)
      blue("==>") + " #{step}"
    end

    def error(error)
      " " + red("!!! Error:") + " #{error}"
    end

    def blue(string)
      Paint[string, :blue]
    end

    def red(string)
      Paint[string, :red, :bright]
    end

    def ok
      " " + Paint["OK", :green]
    end

    def downcase(thing)
      return unless thing
      return thing.underscore if thing.respond_to? :underscore

      thing.each_with_object({}) do |(key, value), obj|
        obj[key.underscore] = value
      end
    end

    def pastel
      @pastel ||= Pastel.new
    end
  end
end

require "#{Focus.root}/lib/focus/formatters/progress_bar"
