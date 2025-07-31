#!/bin/bash

TITLE="Net Watcher"
LOGFILE="/tmp/net_down_log.txt"
STATUS_FILE="/tmp/net_status.txt"

seconds_ifdown=5
seconds_ifup=300
website1="google.com"
website2="duckduckgo.com"
sound_down=~/snd/ds9_odo_console_1.mp3
sound_up=~/snd/ds9_odo_console_2.mp3

# Set up cleanup trap
cleanup() {
    echo "Exiting..."
    kill $YAD_PID $CHECK_PID 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# Start GUI with status and log listbox
(
  echo "Internet status: Checking..."
  echo "Network Log"
) | yad --list --title="$TITLE" --column="" --column="Status/History" --undecorated --no-buttons --width=400 --height=300 --on-top=false --dclick-action="" --no-markup --separator="" --selectable-rows=false --listen --opacity=90 &
YAD_PID=$!

# Get GUI window ID
sleep 0.5
WIN_ID=$(xdotool search --name "$TITLE" | head -n 1)
CONFIG_FILE="$HOME/.config/netwatch-widget.cfg"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    [[ -n "$X_POS" && -n "$Y_POS" ]] &&     wmctrl -i -r "$WIN_ID" -e "0,$X_POS,$Y_POS,-1,-1"
fi

# Force window properties
xprop -id "$WIN_ID" -remove _NET_WM_STATE_SKIP_PAGER
xprop -id "$WIN_ID" -remove _NET_WM_STATE_SKIP_TASKBAR
xprop -id "$WIN_ID" -remove _NET_WM_STATE_ABOVE
xprop -id "$WIN_ID" -f _NET_WM_STATE 32a -set _NET_WM_STATE "_NET_WM_STATE_SKIP_TASKBAR, _NET_WM_STATE_BELOW"

# Set opacity to 90%
xprop -id "$WIN_ID" -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xe6666666


# GUI monitor loop to ensure it stays below
(
  while kill -0 "$YAD_PID" 2>/dev/null; do
      wmctrl -i -r "$WIN_ID" -b remove,above
      wmctrl -i -r "$WIN_ID" -b add,below
      sleep 1
  done
  kill $$  # If YAD closes, kill entire script
) &

# Internet checker loop
prev_webAlive=1

(
  while true; do
      ping -c 1 -W 3 "$website1" > /dev/null 2>&1 || ping -c 1 -W 3 "$website2" > /dev/null 2>&1
      webAlive=$?

      if [[ "$webAlive" -eq 0 ]]; then
          [[ "$prev_webAlive" -ne 0 ]] && mpg123 "$sound_up" > /dev/null 2>&1 &
          echo "Internet status: ONLINE" > "$STATUS_FILE"
      else
          [[ "$prev_webAlive" -eq 0 ]] || (
              echo "$(date): Internet is DOWN" >> "$LOGFILE"
              mpg123 "$sound_down" > /dev/null 2>&1 &
          )
          echo "Internet status: OFFLINE" > "$STATUS_FILE"
      fi

      # Update GUI (status + last 10 log entries)
      (
        echo "$(cat "$STATUS_FILE")"
        tail -n 10 "$LOGFILE" | nl -w2 -s'  ' | while read -r line; do
            echo "$line"
        done
      ) | yad --list --title="$TITLE" --column="" --column="Status/History" --undecorated --no-buttons --width=400 --height=300 --on-top=false --dclick-action="" --no-markup --separator="" --selectable-rows=false --listen --timeout=1 --timeout-indicator=bottom --window-icon=network-wireless &

      sleep $([[ "$webAlive" -eq 0 ]] && echo "$seconds_ifup" || echo "$seconds_ifdown")
      prev_webAlive=$webAlive
  done
) &
CHECK_PID=$!


(
  LAST_POS=""
  while kill -0 "$YAD_PID" 2>/dev/null; do
      CUR_POS=$(xwininfo -id "$WIN_ID" | awk '/Absolute upper-left X|Absolute upper-left Y/ {print $NF}' | paste -sd,)
      if [[ "$CUR_POS" != "$LAST_POS" ]]; then
          X_POS=$(cut -d, -f1 <<< "$CUR_POS")
          Y_POS=$(cut -d, -f2 <<< "$CUR_POS")
          echo "X_POS=$X_POS" > "$CONFIG_FILE"
          echo "Y_POS=$Y_POS" >> "$CONFIG_FILE"
          LAST_POS="$CUR_POS"
      fi
      sleep 5
  done
) &
wait
