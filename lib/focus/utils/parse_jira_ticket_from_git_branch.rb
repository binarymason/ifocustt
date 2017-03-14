module Focus
  module Utils
    class ParseJiraTicketFromGitBranch < Util
      JIRA_TICKET_RGX = /[a-z]+-\d+/i

      def call
        context.jira_ticket = jira_ticket
      end

      private

      def jira_ticket
        git_branch = parse_git_branch
        git_branch.scan(JIRA_TICKET_RGX).first
      end

      def parse_git_branch
        branch = `git rev-parse --abbrev-ref HEAD 2>/dev/null`.chomp
        branch.empty? ? nil : branch
      end
    end
  end
end
