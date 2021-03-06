module Focus
  class PostWorkLogToJira < Action
    def perform
      return unless jira_ticket && seconds_focused >= 60
      Utils::WebClient.post(issue_url, options)
    end

    private

    def issue_url
      "#{config.jira_url}/issue/#{jira_ticket}/worklog"
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
      { username: config.jira_username, password: config.jira_password }
    end

    def headers
      { "Content-Type" => "application/json" }
    end

    def jira_ticket
      context.jira_ticket ||= Utils::ParseJiraTicketFromGitBranch.call.jira_ticket
    end
  end
end
