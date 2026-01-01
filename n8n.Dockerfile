FROM docker.n8n.io/n8nio/n8n:2.0.3

USER root

# Install ImageMagick so `magick` works inside n8n (Execute Command node).
RUN set -eux; \
  if command -v apt-get >/dev/null 2>&1; then \
    apt-get update; \
    apt-get install -y --no-install-recommends imagemagick; \
    rm -rf /var/lib/apt/lists/*; \
  elif command -v apk >/dev/null 2>&1; then \
    apk add --no-cache imagemagick; \
  else \
    echo "No supported package manager found (apt/apk)." >&2; exit 1; \
  fi

USER node
