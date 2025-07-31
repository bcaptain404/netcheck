#!/bin/bash

VERSION="v0.1.1"

# Defaults
seconds_ifdown=5
seconds_ifup=300
website1="google.com"
website2="duckduckgo.com"
sound_down=~/"snd/ds9_odo_console_1.mp3"
sound_up=~/"snd/ds9_odo_console_2.mp3"

print_help() {
  cat <<EOF
net-check.sh $VERSION
Usage: $0 [options]

Checks internet connectivity by pinging a website every N seconds and plays a sound on status change.

Options:
  -S SECONDS       Interval in seconds between checks if net is up (default: $seconds_ifup)
  -s SECONDS       Interval in seconds between checks if net is down (default: $seconds_ifdown)
  -w WEBSITE1      Website1 to ping (default: $website1)
  -W WEBSITE2      Website1 to ping (default: $website2)
  -down FILE       Sound file to play when internet goes down (default: $sound_down)
  -up FILE         Sound file to play when internet comes back up (default: $sound_up)
  --help           Show this help message and exit
  -v               Verbose mode.

Examples:
  $0
  $0 -w example.com -down offline.mp3 -up online.mp3
EOF
}

VERBOSE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s)
      seconds_ifdown="$2"
      shift 2
      ;;
    -S)
      seconds_ifup="$2"
      shift 2
      ;;
    -w)
      website1="$2"
      shift 2
      ;;
    -W)
      website2="$2"
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
    -v)
      VERBOSE="1"
      echo "Verbose mode"
      shift 1
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

# Warn about missing sound files
[[ ! -f "$sound_down" ]] && echo "⚠ Warning: Down sound file '$sound_down' not found. No sound will be played when internet goes down."
[[ ! -f "$sound_up" ]] && echo "⚠ Warning: Up sound file '$sound_up' not found. No sound will be played when internet comes back up."

echo "Starting net-check $VERSION..."
echo " - Up Interval: every $seconds_ifup second(s)"
echo " - Down Interval: every $seconds_ifdown second(s)"
echo " - Website1:  $website1"
echo " - Website2:  $website2"
echo " - Down sound: $sound_down"
echo " - Up sound:   $sound_up"
echo

prev_webAlive=

check_connection() {
  [[ "$VERBOSE" == "1" ]] && echo "pinging..."

  {
    ping -c 1 -W 5 "$website1" > /dev/null 2>&1 || 
    ping -c 1 -W 5 "$website2" > /dev/null 2>&1
  } && webAlive=1 || webAlive=0

  if [[ "$webAlive" -ne "$prev_webAlive" ]]; then
    if [[ "$webAlive" -eq 1 ]]; then
      echo "$(date): Internet is up."
      if [[ -f "$sound_up" ]]; then
        mpg123 "$sound_up" > /dev/null 2>&1 &
      else
        echo "⚠ Cannot play '$sound_up': File not found."
      fi
    else
      echo "$(date): Internet is DOWN!"
      if [[ -f "$sound_down" ]]; then
        mpg123 "$sound_down" > /dev/null 2>&1 &
      else
        echo "⚠ Cannot play '$sound_down': File not found."
      fi
    fi
  fi

  prev_webAlive=$webAlive
}

# Initial check
check_connection

# Loop
while true; do
  if [[ "$prev_webAlive" == "1" ]] ; then
    [[ "$VERBOSE" == "1" ]] && echo "sleeping $seconds_ifup seconds (up)"
    sleep "$seconds_ifup"
  else
    [[ "$VERBOSE" == "1" ]] && echo "sleeping $seconds_ifdown seconds (down)"
    sleep "$seconds_ifdown"
  fi
  check_connection
done
