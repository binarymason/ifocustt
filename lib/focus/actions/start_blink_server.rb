module Focus
  class StartBlinkServer < Action
    def call
      verify_blink_server_installed
      HTTParty.get(config.blink_server)
    rescue Errno::ECONNREFUSED
      start_blink_server
    end

    private

    def verify_blink_server_installed
      error_msg = \
        "Blink server not installed. Run `npm install -g node-blink1-server`."

      raise ArgumentError, error_msg unless blink_server_installed?
    end

    def blink_server_installed?
      system("command -v blink1-server &>/dev/null")
    end

    def start_blink_server
      fork do
        system("blink1-server #{config.blink_port} &>/dev/null")
      end
    end
  end
end
