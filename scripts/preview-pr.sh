#!/bin/sh
# Serve a pull request's public/ on the tailnet so Matt can see the site before merging.
#
#   scripts/preview-pr.sh <pr-number>          start, or refresh after new commits
#   scripts/preview-pr.sh --stop <pr-number>   retire it after the PR merges or closes
#
# Each PR gets its own port (5700 + PR number) because the site uses absolute paths
# (/img/...). The preview runs as a LaunchAgent, so it survives restarts, and Tailscale
# Serve exposes it to the tailnet only, never publicly. It needs this Mac to be awake.
set -eu

stop=0
if [ "${1:-}" = "--stop" ]; then stop=1; shift; fi
n="${1:-}"
case "$n" in ''|*[!0-9]*) echo "usage: $0 [--stop] <pr-number>" >&2; exit 2;; esac

port=$((5700 + n))
base="$HOME/peak-mind-previews"
root="$base/pr-$n"
label="com.peakmind.preview.pr$n"
plist="$HOME/Library/LaunchAgents/$label.plist"
domain="gui/$(id -u)"

if [ "$stop" = 1 ]; then
  tailscale serve --https="$port" off >/dev/null 2>&1 || true
  launchctl bootout "$domain/$label" >/dev/null 2>&1 || true
  rm -f "$plist"
  rm -rf "$root" "$root.next"
  echo "Retired the preview for PR #$n (port $port)."
  exit 0
fi

repo=$(git rev-parse --show-toplevel)
git -C "$repo" fetch -q origin "pull/$n/head"
sha=$(git -C "$repo" rev-parse FETCH_HEAD)

# Swap in the new copy only after it is fully extracted.
mkdir -p "$base"
rm -rf "$root.next"
mkdir "$root.next"
git -C "$repo" archive "$sha" public | tar -x -C "$root.next" --strip-components=1
rm -rf "$root"
mv "$root.next" "$root"

python=$(command -v python3)
cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key><array>
    <string>$python</string><string>-m</string><string>http.server</string>
    <string>--bind</string><string>127.0.0.1</string><string>$port</string>
    <string>--directory</string><string>$root</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict></plist>
PLIST
launchctl bootout "$domain/$label" >/dev/null 2>&1 || true
launchctl bootstrap "$domain" "$plist"
tailscale serve --bg --https="$port" "http://127.0.0.1:$port" >/dev/null

host=$(tailscale status --json | "$python" -c 'import json, sys; print(json.load(sys.stdin)["Self"]["DNSName"].rstrip("."))')
url="https://$host:$port/"
i=0
until curl -fsS -o /dev/null "$url"; do
  i=$((i + 1))
  if [ "$i" -ge 20 ]; then echo "Preview did not answer at $url" >&2; exit 1; fi
  sleep 0.5
done
echo "PR #$n preview ($(echo "$sha" | cut -c1-7)): $url"
