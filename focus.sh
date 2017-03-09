#!/bin/sh
#
# USAGE:
#
# focus [minutes=25] [target=?|JIRA ticket in git branch]

git_branch_name() { git rev-parse --abbrev-ref HEAD 2>/dev/null; }
jira_ticket() {
  local branch=$(git_branch_name)
  local ticket=$(echo $branch | sed 's/.*\([a-zA-Z]\{2\}-[0-9]\{2\}\)/\1/') # TODO
  if [ "$ticket" == "$branch" ]
  then
    echo "?"
  else
    echo "$ticket"
  fi
}

FOCUS_MINUTES="${1-25}"
FOCUS_TARGET="${2-$(jira_ticket)}"
FOCUS_HISTORY_FILE="$HOME/.focus_history"

info() { printf -- "\033[00;34m..\033[0m  %s " "$*"; }
ok() { echo "\033[00;32m✓\033[0m"; }
abort() { echo "!!! $*" >&2; exit 1; }
epoch() { date +%s; }
print_line() { printf "%-15s %-15s %-15s\n" "$1" "$2" "$3"; }
title() { print_line "EPOCH" "FOCUS_TIME" "TARGET"; }
event() { print_line "$(epoch)" "$FOCUS_MINUTES" "$@"; }
add_to_history() { "$@" >> "$FOCUS_HISTORY_FILE"; }

log_focus() {
  info "Updating ~/.focus_history"
  if [ ! -f "$FOCUS_HISTORY_FILE" ]; then add_to_history title; fi
  add_to_history event "$FOCUS_TARGET"
  ok
}

quietly() {
  "$@" &>/dev/null
}

SLACK_TOKEN=$(cat ~/.secrets/slack-token 2>/dev/null)
SLACK_AWAY="away"
SLACK_AVAILABLE="auto"

change_slack_presence() {
  if [ -n "$SLACK_TOKEN" ]
  then
    local presence="$1"
    info "Changing slack presence to $presence"
    local setpresenceurl="https://slack.com/api/users.setPresence?token=$SLACK_TOKEN&presence=$presence&pretty=1"
    curl -X POST "$setpresenceurl" &>/dev/null && ok
  fi
}

BLINK_PORT="8754"
BLINK_SERVER="http://localhost:$BLINK_PORT/blink1"
BLINK_RED="23EA5B5B"
BLINK_GREEN="233AF23A"
BLINK_ORANGE="23FFBF00"
start_blink_server() {
  if ! command -v blink1-server &> /dev/null
  then
    abort 'Blink server not installed. Run `npm install -g node-blink1-server`.'
  else
    quietly curl "$BLINK_SERVER" || blink1-server "$BLINK_PORT" &
  fi
}

change_blink_color() {
  local color="$1"
  info "Changing blink to $color"
  curl "$BLINK_SERVER/fadeToRGB?rgb=%$color" &>/dev/null && ok
}

strobe_blink_color() {
  local color="$1"
  local seconds="$2"
  local blink_rate="0.5" # both on and off together finishes in one second
  curl "$BLINK_SERVER/blink?rgb=%$color&time=$blink_rate&repeats=$seconds" &>/dev/null && ok
}

IFTTT_MAKER_KEY=$(cat ~/.secrets/ifttt-maker 2>/dev/null)
start_rescue_time() {
  if [ -n "$IFTTT_MAKER_KEY" ]
  then
    local event="rescue_time_focus_start"
    info "Firing $event blink(1) event to IFTT"
    curl -X POST https://maker.ifttt.com/trigger/${event}/with/key/${IFTTT_MAKER_KEY} &>/dev/null && ok
  fi
}

start_slack_do_not_disturb() {
  if [ -n "$SLACK_TOKEN" ]
  then
    local url="https://slack.com/api/dnd.setSnooze?token=$SLACK_TOKEN&num_minutes=$FOCUS_MINUTES&pretty=1"
    info "Changing slack to do not disturb for $FOCUS_MINUTES minutes"
    curl -X POST "$url" &>/dev/null && ok
  fi
}

disable_mac_notification_center() {
  if [ "$(uname)" == "Darwin" ]
  then
    info "Disabling Mac OSX notification center"
    quietly launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
    ok
  fi
}

enable_mac_notification_center() {
  if [ "$(uname)" == "Darwin" ]
  then
    launchctl load -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
  fi
}

cleanup(){
  local focus_seconds=$(echo "$FOCUS_MINUTES * 60" | bc)
  local break_seconds=$(echo "$focus_seconds * .2" | bc)
  sleep "$focus_seconds" && quietly strobe_blink_color "$BLINK_ORANGE" "$break_seconds"
  sleep "$break_seconds" && \
    quietly change_slack_presence "$SLACK_AVAILABLE"
    quietly enable_mac_notification_center
    quietly change_blink_color "$BLINK_GREEN"
}

disable_mac_notification_center
start_rescue_time
start_blink_server
change_slack_presence "$SLACK_AWAY"
start_slack_do_not_disturb
log_focus
change_blink_color "$BLINK_RED"
cleanup &
