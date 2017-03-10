module Focus
  class StartBlinkServer < Action
    def call
      verify_blink_server_installed
      res = HTTParty.get(BLINK_SERVER)
      start_blink_server if res.code != 200
    end

    private

    def verify_blink_server_installed
      error_msg = <<~EOF
      Blink server not installed. Run `npm install -g node-blink1-server`.
      EOF

      context.fail!(error: error_msg) unless blink_server_installed?
    end

    def blink_server_installed?
      system("command -v blink1-server &>/dev/null")
    end

    def start_blink_server
      fork do
        system("blink1-server #{BLINK_PORT}")
      end
    end
  end
end
