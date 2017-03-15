module Focus
  class RunShellCommand < Action
    def call
      system(context.command.to_s)
    end
  end
end
