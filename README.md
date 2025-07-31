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

## 🚀 Usage

```bash
./net-check.sh [options]
