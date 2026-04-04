#!/usr/bin/env bash

# This script runs the Godot game tour in a virtual framebuffer (Xvfb)
# and collects artifacts for the final report.

set -euo pipefail

# Config
SCREENSHOT_DIR="${SCREENSHOT_DIR:-/workspace/artifacts/tour}"
REPORT_PATH="${REPORT_PATH:-/workspace/artifacts/tour_report.json}"
PROJECT_PATH="${PROJECT_PATH:-/workspace/project}"
USER_DATA_DIR="/tmp/godot/app_userdata/Coral Clicker"

mkdir -p "$SCREENSHOT_DIR"
mkdir -p "$USER_DATA_DIR"

echo "[SH] Starting Xvfb..."
Xvfb :99 -screen 0 1280x720x24 &
export DISPLAY=:99

# Give Xvfb a moment to start
sleep 2

echo "[SH] Running Godot Tour..."
# Use --audio-driver Dummy to avoid sound errors in Docker
# Use --rendering-driver opengl3 for software rendering stability in CI/Docker
godot --path "$PROJECT_PATH" \
    --audio-driver Dummy \
    --rendering-driver opengl3 \
    "res://tests/tour.tscn" \
    2>&1 | tee /tmp/godot_tour.log

EXIT_CODE=$?

echo "[SH] Godot exited with code $EXIT_CODE"

# The tour_runner script saves screenshots to user://tour_screenshots
# and the report to user://tour_report.json
# We need to move them to the artifacts directory.

# Find where Godot actually saved things
# If GODOT_USER_DIR was /tmp/godot, then:
# user:// maps to /tmp/godot/app_userdata/Coral Clicker/

INTERNAL_SCREENSHOTS="$USER_DATA_DIR/tour_screenshots"
INTERNAL_REPORT="$USER_DATA_DIR/tour_report.json"

if [ -d "$INTERNAL_SCREENSHOTS" ]; then
    echo "[SH] Copying screenshots..."
    cp -r "$INTERNAL_SCREENSHOTS"/* "$SCREENSHOT_DIR/"
fi

if [ -f "$INTERNAL_REPORT" ]; then
    echo "[SH] Copying report..."
    cp "$INTERNAL_REPORT" "$REPORT_PATH"
fi

# Correlation of logs
if [ -f "$REPORT_PATH" ]; then
    echo "[SH] Correlating logs into report..."
    # The tour_runner script already includes logs it captured,
    # but we can also append the full console log if there was an error.
    if [ $EXIT_CODE -ne 0 ]; then
        echo "[SH] Error detected, appending full console log to report..."
        # We could use jq to update the JSON, but for simplicity let's just 
        # ensure the log is available as a separate file.
        cp /tmp/godot_tour.log "/workspace/artifacts/godot_console.log"
    fi
else
    if [ $EXIT_CODE -ne 0 ]; then
        echo "[SH] Report not found but Godot failed. Saving console log."
        cp /tmp/godot_tour.log "/workspace/artifacts/godot_console_error.log"
    fi
fi

# Cleanup if successful (as requested)
if [ $EXIT_CODE -eq 0 ]; then
    echo "[SH] Tour successful. Cleaning up internal report."
    # The tour_runner already calls _cleanup_success, but we'll be sure.
    # Note: the user said "the file should be deleted... if the test runs without any issues"
    # I will delete the artifacts report if successful.
    rm -f "$REPORT_PATH"
    # Optionally remove screenshots too if the user wants total silence on success
    # rm -rf "$SCREENSHOT_DIR"
else
    echo "[SH] Tour failed. Artifacts preserved in /workspace/artifacts/"
fi

exit $EXIT_CODE
