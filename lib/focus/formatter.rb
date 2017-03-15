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

    def pastel
      @pastel ||= Pastel.new
    end
  end
end
