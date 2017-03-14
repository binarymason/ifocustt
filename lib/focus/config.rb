require "dotenv"

module Focus
  class Config < OpenStruct
    class << self
      def method_missing(m, *args, &block) # rubocop:disable MethodMissing
        config.send(m, *args, &block)
      end

      def config
        @config ||= new
      end
    end

    def initialize
      source_env
      super(configurations)
      ingest _hardcoded
    end

    private

    def configurations
      defaults.merge(custom_config)
    end

    def ingest(hsh)
      hsh.each do |key, value|
        send("#{key}=", value)
      end
    end

    def custom_config
      @custom_config ||= Focus::ConfigLoader.load("config")
    end

    def defaults
      {
        "blink_port"         => ENV["BLINK_PORT"]         || 8754,
        "focus_history_file" => ENV["FOCUS_HISTORY_FILE"] || "#{ENV['HOME']}/.focus_history",
        "focus_minutes"      => ENV["FOCUS_MINUTES"]      || 25,
        "slack_api_url"      => ENV["SLACK_API_URL"]      || "https://slack.com/api",
        "ifttt_maker_key"    => ENV["IFTTT_MAKER_KEY"],
        "slack_token"        => ENV["SLACK_TOKEN"]
      }
    end

    def _hardcoded
      raise "`blink_port` was not defined" unless blink_port

      {
        "blink_server"    => "http://localhost:#{blink_port}/blink1",
        "slack_available" => "auto",
        "slack_away"      => "away"
      }
    end

    def source_env
      return unless custom_config.respond_to? :keys
      relative_path = custom_config["env_file"] || ".env"
      path = File.expand_path relative_path

      return unless File.exist?(path)
      Dotenv.load path
    end
  end
end
