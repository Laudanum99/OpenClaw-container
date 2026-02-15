#!/bin/bash
set -e

# Define paths
# Define paths
DATA_DIR="/home/node/app/data"
CONFIG_FILE="openclaw.json"

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

# Ensure standard config directory exists
mkdir -p /home/node/.openclaw

# Export API Keys for providers
export OPENAI_API_KEY="$LLM_API_KEY"
export DEEPSEEK_API_KEY="$LLM_API_KEY"
export ANTHROPIC_API_KEY="$LLM_API_KEY"

# Handle Deepseek via OpenAI compatibility
# Handle Deepseek via OpenAI compatibility
if [ "$LLM_PROVIDER" = "deepseek" ] || [ "$LLM_PROVIDER" = "deepseek-chat" ]; then
    # Force default model to deepseek-chat
    LLM_MODEL="${LLM_MODEL:-deepseek-chat}"
    # Use openai provider alias for compatibility
    LLM_PROVIDER="openai"
    # Set Deepseek API Base URL
    if [ -z "$LLM_BASE_URL" ]; then
        LLM_BASE_URL="https://api.deepseek.com"
    fi
    # Must export OPENAI vars for provider/model alias to work
    export OPENAI_BASE_URL="$LLM_BASE_URL"
    export OPENAI_API_KEY="$LLM_API_KEY"
fi

# Set default token for Gateway access (required for non-loopback bind)
export OPENCLAW_GATEWAY_TOKEN="${GATEWAY_TOKEN:-magi}"

# OpenClaw @latest Config Schema
CONFIG_FILE="/home/node/.openclaw/openclaw.json"

echo "Generating $CONFIG_FILE configuration..."

# Construct model string (provider/model)
MODEL_STRING="${LLM_PROVIDER:-openai}/${LLM_MODEL:-gpt-4-turbo}"

cat <<EOF > "$CONFIG_FILE"
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "port": 3000
  },
  "agents": {
    "defaults": {
      "workspace": "$DATA_DIR/workspace",
      "model": {
        "primary": "$MODEL_STRING"
      }
    }
  }
}
EOF

echo "Configuration generated."
echo "OPENCLAW_CONFIG=$CONFIG_FILE"
export OPENCLAW_CONFIG="$CONFIG_FILE"

# Execute OpenClaw
echo "Starting OpenClaw Gateway..."
exec openclaw gateway run --port 3000 "$@"
