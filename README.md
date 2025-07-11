# net-check.sh

**Version:** v0.1.0  
**License:** MIT

`net-check.sh` is a minimalist Bash script that checks your internet connectivity on a schedule and plays a sound when it drops or recovers.

## ✅ Features

- Pings a website every N minutes
- Detects when connection is lost or restored
- Plays customizable sounds for each event
- Sane defaults so you can just run it

## 🧪 Default Behavior

With no arguments provided, it:

- Pings `google.com`
- Every `30` minutes
- Plays `down.wav` when offline
- Plays `up.wav` when back online

## Dependencies
 - mpg123

## 🚀 Usage

```bash
./net-check.sh [options]
