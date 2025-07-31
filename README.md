# net-check.sh

**Version:** v0.1.0  
**License:** MIT

`net-check.sh` is a minimalist Bash script that checks your internet connectivity on a schedule and plays a sound when it drops or recovers.

## ✅ Features

- Pings a website every N seconds
- Detects when connection is lost or restored
- Plays customizable sounds for each event
- Sane defaults so you can just run it
- netwatcher-widget.sh is a GUI desktop widget version of the script.
- Plays a sound when offline
- Plays a sound when back online
- Desktop widget saves position to ~/.config/netwatch-widget.cfg
- Saves net connection history to /tmp/net_down_log.txt
- Saves current connectivity status to /tmp/net_status.txt


## Dependencies
 - bash
 - ping
 - mpg123

## Desktop Widget Dependencies
 - all the previous dependencies
 - yad
 - xdotool
 - xprop
 - xwininfo
 - wmctrl

to install them on Ubuntu: sudo apt install yad xdotool x11-utils wmctrl mpg123

## 🚀 Usage

```bash
./net-check.sh [options]
