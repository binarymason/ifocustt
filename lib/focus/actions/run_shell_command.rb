module Focus
  class RunShellCommand < Action
    def call
      system(context.cmd)
    end
  end
end
