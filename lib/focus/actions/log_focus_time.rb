require "fileutils"
module Focus
  class LogFocusTime < Action
    def perform
      update_log
    end

    private

    def update_log
      file = File.expand_path config.focus_history_file
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

    def focus_target
      jira_ticket || super
    end

    def jira_ticket
      @ticket ||= Utils::ParseJiraTicketFromGitBranch.call.jira_ticket
    end
  end
end
