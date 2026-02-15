#!/bin/bash
set -e

# Define paths
DATA_DIR="/home/node/app/data"
CONFIG_FILE="$DATA_DIR/config.json"

# Critical Permission Check
# We verify if the current user (node) has write permissions on $DATA_DIR
if [ ! -w "$DATA_DIR" ]; then
    echo "CRITICAL ERROR: The data directory '$DATA_DIR' is not writable by the current user (uid=$(id -u))."
    echo "Please ensure the host volume is mounted with correct permissions (e.g., chown 1000:1000)."
    exit 1
fi

# Volume Initialization
# If the data directory is empty, we initialize the structure
if [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
    echo "Initializing data directory at $DATA_DIR..."
    mkdir -p "$DATA_DIR/workspace"
    mkdir -p "$DATA_DIR/memory"
    mkdir -p "$DATA_DIR/sessions"
else
    echo "Data directory $DATA_DIR is not empty, skipping initialization."
fi

# Dynamic Config Generation
# We create config.json from environment variables
echo "Generating $CONFIG_FILE configuration..."

cat <<EOF > "$CONFIG_FILE"
{
  "llm": {
    "provider": "${LLM_PROVIDER:-openai}",
    "apiKey": "${LLM_API_KEY}",
    "model": "${LLM_MODEL:-gpt-4-turbo}"
  },
  "integrations": {
    "google": {
      "refreshToken": "${GOOGLE_REFRESH_TOKEN}"
    },
    "github": {
      "token": "${GITHUB_TOKEN}"
    }
  },
  "browser": {
    "executablePath": "/usr/bin/chromium",
    "headless": true
  },
  "agent": {
    "workspace": "$DATA_DIR/workspace",
    "memory": "$DATA_DIR/memory"
  }
}
EOF

echo "Configuration generated."

# Execute OpenClaw
echo "Starting OpenClaw Gateway..."
# Pass through any additional arguments to the gateway
exec openclaw gateway --config "$CONFIG_FILE" --port 3000 "$@"
