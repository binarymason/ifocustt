module Focus
  class LogWorkForJira < Action
    JIRA_TICKET_RGX = /[a-z]+-\d+/i

    def call
      return unless git_branch && jira_ticket
      LogFocusTime.call(minutes: focus_minutes, target: jira_ticket)
    end

    private

    def git_branch
      @branch ||= parse_git_branch
    end

    def parse_git_branch
      branch = `git rev-parse --abbrev-ref HEAD 2>/dev/null`.chomp
      branch.empty? ? nil : branch
    end

    def jira_ticket
      @ticket ||= git_branch.scan(JIRA_TICKET_RGX).first
    end
  end
end
