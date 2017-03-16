module Focus
  class ToggleMacNotificationCenter < Action
    def perform
      fail_action!(error: "This action only works on MacOSX") unless mac?
      toggle
    end

    private

    def mac?
      uname == "Darwin"
    end

    def uname
      `uname`.chomp
    end

    def toggle
      `launchctl #{setting} -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist &>/dev/null`

      if context.enabled?
        `killall NotificationCenter &>/dev/null`
      else
        `open -a NotificationCenter &>/dev/null`
      end
    end

    def setting
      context.enabled ? "load" : "unload"
    end
  end
end
