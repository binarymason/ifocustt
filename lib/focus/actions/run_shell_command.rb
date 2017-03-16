module Focus
  class RunShellCommand < Action
    def perform
      system(context.command.to_s)
    end
  end
end
