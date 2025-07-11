#!/bin/bash

VERSION="v0.1.0"

# Defaults
minutes=30
website="google.com"
sound_down="down.wav"
sound_up="up.wav"

print_help() {
  cat <<EOF
net-check.sh $VERSION
Usage: $0 [options]

Checks internet connectivity by pinging a website every N minutes and plays a sound on status change.

Options:
  -m MINUTES       Interval in minutes between checks (default: 30)
  -w WEBSITE       Website to ping (default: google.com)
  -down FILE       Sound file to play when internet goes down (default: down.wav)
  -up FILE         Sound file to play when internet comes back up (default: up.wav)
  --help           Show this help message and exit

Examples:
  $0
  $0 -m 5 -w example.com -down offline.wav -up online.wav
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -m)
      minutes="$2"
      shift 2
      ;;
    -w)
      website="$2"
      shift 2
      ;;
    -down)
      sound_down="$2"
      shift 2
      ;;
    -up)
      sound_up="$2"
      shift 2
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Try '$0 --help' for usage."
      exit 1
      ;;
  esac
done

interval=$((minutes * 60))

# Warn about missing sound files
[[ ! -f "$sound_down" ]] && echo "⚠ Warning: Down sound file '$sound_down' not found. No sound will be played when internet goes down."
[[ ! -f "$sound_up" ]] && echo "⚠ Warning: Up sound file '$sound_up' not found. No sound will be played when internet comes back up."

echo "Starting net-check $VERSION..."
echo " - Interval: every $minutes minute(s)"
echo " - Website:  $website"
echo " - Down sound: $sound_down"
echo " - Up sound:   $sound_up"
echo

prev_webAlive=

while true; do
  if ping -c 1 -W 5 "$website" > /dev/null 2>&1; then
    webAlive=1
  else
    webAlive=0
  fi

  if [[ "$webAlive" -ne "$prev_webAlive" ]]; then
    if [[ "$webAlive" -eq 1 ]]; then
      echo "$(date): Internet is back up."
      if [[ -f "$sound_up" ]]; then
        mpg123 "$sound_up" > /dev/null 2>&1 &
      else
        echo "⚠ Cannot play '$sound_up': File not found."
      fi
    else
      echo "$(date): Internet is down!"
      if [[ -f "$sound_down" ]]; then
        mpg123 "$sound_down" > /dev/null 2>&1 &
      else
        echo "⚠ Cannot play '$sound_down': File not found."
      fi
    fi
  fi

  prev_webAlive=$webAlive
  sleep "$interval"
done
