#!/bin/sh
#
# USAGE:
# focus [minutes] (Defaults to 25)

FOCUS_MINUTES="${1-25}"

IFTTT_MAKER_KEY=$(cat ~/.secrets/ifttt-maker)
SLACK_TOKEN=$(cat ~/.secrets/slack-token)
SLACK_AWAY="away"
SLACK_AVAILABLE="auto"
BLINK_PORT="8754"
BLINK_SERVER="http://localhost:$BLINK_PORT/blink1"
BLINK_RED="23EA5B5B"
BLINK_GREEN="233AF23A"

info() { printf -- "\033[00;34m..\033[0m  %s " "$*"; }
ok() { echo "\033[00;32m✓\033[0m"; }

change_slack_presence() {
  local presence="$1"
  info "Changing slack presence to $presence"
  local setpresenceurl="https://slack.com/api/users.setPresence?token=$SLACK_TOKEN&presence=$presence&pretty=1"
  curl -X POST "$setpresenceurl" &>/dev/null && ok
}

start_blink_server() {
  curl "$BLINK_SERVER" &>/dev/null || blink1-server "$BLINK_PORT" &
}

change_blink_color() {
  local color="$1"
  info "Changing blink to $color"
  curl "$BLINK_SERVER/fadeToRGB?rgb=%$color" &>/dev/null && ok
}

start_rescue_time() {
  local event="rescue_time_focus_start"
  info "Firing $event blink(1) event to IFTT"
  curl -X POST https://maker.ifttt.com/trigger/${event}/with/key/${IFTTT_MAKER_KEY} &>/dev/null && ok
}

start_slack_do_not_disturb() {
  local url="https://slack.com/api/dnd.setSnooze?token=$SLACK_TOKEN&num_minutes=$FOCUS_MINUTES&pretty=1"
  info "Changing slack to do not disturb for $FOCUS_MINUTES minutes"
  curl -X POST "$url" &>/dev/null && ok
}

quietly() {
  "$@" &>/dev/null
}

cleanup(){
  local focus_seconds="$(expr $FOCUS_MINUTES \* 60)"
  sleep "$focus_seconds" && \
    quietly change_slack_presence "$SLACK_AVAILABLE"
    quietly change_blink_color "$BLINK_GREEN"
}

start_rescue_time
start_blink_server
change_blink_color "$BLINK_RED"
change_slack_presence "$SLACK_AWAY"
start_slack_do_not_disturb
cleanup &
