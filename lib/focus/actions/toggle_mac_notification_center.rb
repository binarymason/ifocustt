module Focus
  class ToggleMacNotificationCenter < Action
    def call
      toggle if uname == "Darwin"
    end

    private

    def uname
      `uname`.chomp
    end

    def toggle
      setting = context.enabled ? "load" : "unload"
      `launchctl #{setting} -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist &>/dev/null`
    end
  end
end
