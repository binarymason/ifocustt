require "fileutils"
module Focus
  class LogFocusTime < Action
    def call
      update_log
    end

    private

    def update_log
      file = FOCUS_HISTORY_PATH
      new_file = File.exist?(file)

      File.open(file, "a") do |fo|
        fo.puts title unless new_file
        fo.puts entry(Time.now.to_i, focus_minutes, focus_target)
      end
    end

    def entry(epoch, min, target)
      line % [epoch, min, target]
    end

    def line
      "%-20s %-20s %s"
    end

    def title
      entry "EPOCH", "FOCUS_MINUTES", "TARGET"
    end
  end
end
