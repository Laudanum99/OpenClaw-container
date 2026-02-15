# Ultimate Edition Dockerfile for OpenClaw Engine
FROM node:22-bookworm-slim

# Install system dependencies
# We maintain Apt lists only during the build to keep the image small
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    python3 \
    python3-pip \
    python3-dev \
    ffmpeg \
    build-essential \
    make \
    g++ \
    git \
    curl \
    wget \
    unzip \
    tar \
    procps \
    ripgrep \
    jq \
    dumb-init \
    fonts-liberation \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Ensure node user exists and set up app directory
# The node image usually comes with a 'node' user, but we ensure permissions
USER node
WORKDIR /home/node/app

# Copy entrypoint script (assuming it's in the same directory as Dockerfile)
COPY --chown=node:node entrypoint.sh /home/node/app/entrypoint.sh

# Entrypoint setup
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/home/node/app/entrypoint.sh"]
