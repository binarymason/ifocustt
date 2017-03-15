module Focus
  class PostWorkLogToJira < Action
    def call
      return unless jira_ticket && seconds_focused >= 60
      HTTParty.post(issue_url, options)
    end

    private

    def issue_url
      "#{Config.jira_url}/issue/#{jira_ticket}/worklog"
    end

    def options
      {
        body:       body.to_json,
        basic_auth: auth,
        headers:    headers
      }
    end

    def body
      { timeSpentSeconds: seconds_focused, comment: context.comment.to_s }
    end

    def auth
      { username: Config.jira_username, password: Config.jira_password }
    end

    def headers
      { "Content-Type" => "application/json" }
    end

    def jira_ticket
      context.jira_ticket ||= Utils::ParseJiraTicketFromGitBranch.call.jira_ticket
    end
  end
end
